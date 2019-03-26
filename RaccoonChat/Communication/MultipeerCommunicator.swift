//
//  MultipeerCommunicator.swift
//  RaccoonChat
//
//  Created by Анна Якусевич on 18/03/2019.
//  Copyright © 2019 Hanna Yakusevych. All rights reserved.
//

import Foundation
import MultipeerConnectivity

class MultipeerCommunicator: NSObject, Communicator {
  
  weak var delegate: CommunicatorDelegate?
  
  // TODO: implement
  // For now our user is always online
  var online: Bool = true
  
  // MARK: - Connection members
  private var sessions = [MCPeerID: MCSession]()
  private var advertiser: MCNearbyServiceAdvertiser!
  private var browser: MCNearbyServiceBrowser!
  let serviceType = "tinkoff-chat"
  
  // TODO: Load the user name
  let myPeerId = MCPeerID(displayName: UIDevice.current.name)
  
  // Lists for all found peers
  var onlineUsers = [User]()
  var historyUsers = [User]()
  
  // MARK: - Init
  override init() {
    super.init()
    
    //myPeerId = MCPeerID(displayName: UIDevice.current.name)
    
    browser = MCNearbyServiceBrowser(peer: myPeerId, serviceType: serviceType)
    browser.delegate = self
    
    advertiser = MCNearbyServiceAdvertiser(peer: myPeerId, discoveryInfo:  ["userName" : myPeerId.displayName], serviceType: serviceType)
    advertiser.delegate = self
    
    browser.startBrowsingForPeers()
    advertiser.startAdvertisingPeer()
  }
  
  // MARK: - Communicator protocol conformance
  func sendMessage(string: String, to userId: String, completionHandler: ((Bool, Error?) -> ())) {
    let jsonMessage: [String: String] =  ["eventType": "TextMessage",
                                          "messageId": generateMessageId() ,
                                          "text": string]
    let dataToSend = NSKeyedArchiver.archivedData(withRootObject: jsonMessage)
    if let user = onlineUsers.first(where: {$0.name == userId}) {
      do {
        try sessions[user.peerId]?.send(dataToSend, toPeers: [user.peerId], with: MCSessionSendDataMode.unreliable)
        completionHandler(true, nil)
      } catch {
        completionHandler(false, error)
      }
    } else {
      completionHandler(false, nil)
    }
  }
  
  private func generateMessageId() -> String {
    let string = "\(arc4random_uniform(UINT32_MAX))+\(Date.timeIntervalSinceReferenceDate)+\(arc4random_uniform(UINT32_MAX))".data(using: .utf8)?.base64EncodedString()
    return string!
  }
  
  // Make new session and invite user to it
  func inviteUser(peerId: MCPeerID) {
    let session = MCSession(peer: myPeerId, securityIdentity: nil, encryptionPreference: .optional)
    session.delegate = self
    sessions[peerId] = session
    browser.invitePeer(peerId, to: session, withContext: nil, timeout: 30)
    Logger.write("User is invited")
  }
}

// MARK: - MCSessionDelegate
extension MultipeerCommunicator: MCSessionDelegate {
  func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
    switch state{
    case MCSessionState.connected:
      print("Connected to session: \(session)")
      if let user = onlineUserWith(peerID: peerID) {
        user.connected = true
      }
    case MCSessionState.connecting:
      print("Connecting to session: \(session)")
      if let user = onlineUserWith(peerID: peerID) {
        user.connected = false
      }
    default:
      print("Did not connect to session: \(session)")
      if let user = onlineUserWith(peerID: peerID) {
        user.connected = false
      }
    }
  }
  
  // Helping function - check if user with peerID is in onlineUsers
  private func onlineUserWith(peerID: MCPeerID) -> User? {
    for user in onlineUsers {
      if user.peerId == peerID {
        return user
      }
    }
    return nil
  }
  
  func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
    let dataDictionary = NSKeyedUnarchiver.unarchiveObject(with: data) as! Dictionary<String, String>
    delegate?.didReceiveMessage(text: dataDictionary["text"]!, fromUser: peerID.displayName, toUser: myPeerId.displayName)
  }
  
  func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
    // TODO: For now user can't receive streams
  }
  
  func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
    // TODO: implement
  }
  
  func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {
    // TODO: implement
  }
}

// MARK: - MCNearbyServiceBrowserDelegate
extension MultipeerCommunicator: MCNearbyServiceBrowserDelegate {
  func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
    // If user is already online, do nothing
    if onlineUserWith(peerID: peerID) != nil {
      return
    }
    
    // Check if user was connected during the session
    // Then return it to online section
    for (index, user) in self.historyUsers.enumerated() {
      if user.peerId == peerID {
        historyUsers.remove(at: index)
        user.online = true
        onlineUsers.append(user)
        delegate?.didFoundUser(userID: peerID.displayName, userName: user.name)
        return
      }
    }
    
    // Else it is a new user - add it to the list
    onlineUsers.append(User(peerId: peerID))
    guard let discovery = info, let name = discovery["userName"] else {
      delegate?.didFoundUser(userID: peerID.displayName, userName: nil)
      return
    }
    delegate?.didFoundUser(userID: peerID.displayName, userName: name)
  }
  
  func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
    for (index, user) in self.onlineUsers.enumerated() {
      if user.peerId == peerID {
        onlineUsers.remove(at: index)
        user.online = false
        // If chat wasn't empty, save it till the end of session
        if user.chatHistory.count > 0 {
          historyUsers.append(user)
        }
        break
      }
    }
    delegate?.didLostUser(userID: peerID.displayName)
  }
  
  func browser(_ browser: MCNearbyServiceBrowser, didNotStartBrowsingForPeers error: Error) {
    delegate?.failedToStartBrowsingForUsers(error: error)
  }
  
}

// MARK: - MCNearbyServiceAdvertiserDelegate
extension MultipeerCommunicator: MCNearbyServiceAdvertiserDelegate {
  func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
    // If the session for this user already exists
    if sessions[peerID] != nil {
      invitationHandler(false, nil)
      return
    }
    let session = MCSession(peer: myPeerId, securityIdentity: nil, encryptionPreference: .optional)
    session.delegate = self
    sessions[peerID] = session
    invitationHandler(true, session)
    Logger.write("Connection is established")
  }
  func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didNotStartAdvertisingPeer error: Error) {
    delegate?.failedToStartAdvertising(error: error)
  }
  
}

// MARK: - Helping structs (data source)
class User {
  var name = "Name"
  var peerId: MCPeerID
  var message: String? { return chatHistory.last?.text  }
  var date: Date? { return chatHistory.last?.date }
  var hasUnreadMessages = false
  var online = true
  var connected = false
  var photo: UIImage? = nil
  var chatHistory = [Message]()
  
  init(peerId: MCPeerID) {
    self.peerId = peerId
    self.name = peerId.displayName
  }
  
  static func sortUsers(lhs: User, rhs: User) -> Bool {
    switch (lhs.date, rhs.date) {
    case (nil, nil):
      return lhs.name < rhs.name
    case (nil, _):
      return false
    case ( _, nil):
      return true
    case (let x, let y):
      return x! < y!
    }
  }
}

struct Message {
  let isInput: Bool
  let text: String
  let date: Date
}
