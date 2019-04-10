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
  var online: Bool = true

  // MARK: - Connection members
  private var sessions = [String: MCSession]()
  private var advertiser: MCNearbyServiceAdvertiser!
  private var browser: MCNearbyServiceBrowser!
  let serviceType = "tinkoff-chat"

  var myPeerId: MCPeerID = MCPeerID(displayName: UserDefaults.standard.string(forKey: "name") ?? "Name undefined")

  // MARK: - Init
  override init() {
    super.init()

    //myPeerId = MCPeerID(displayName: UIDevice.current.name)

    self.browser = MCNearbyServiceBrowser(peer: myPeerId, serviceType: serviceType)
    self.browser.delegate = self

    self.advertiser = MCNearbyServiceAdvertiser(peer: myPeerId, discoveryInfo: ["userName": myPeerId.displayName], serviceType: serviceType)
    self.advertiser.delegate = self

    self.browser.startBrowsingForPeers()
    self.advertiser.startAdvertisingPeer()
  }

  // MARK: - Communicator protocol conformance
  func sendMessage(string: String, to userId: String, completionHandler: ((Bool, Error?) -> Void)) {
    if let session = sessions[userId] {
      let jsonMessage =  ["eventType": "TextMessage",
                          "messageId": generateMessageId() ,
                          "text": string]
      let dataToSend = NSKeyedArchiver.archivedData(withRootObject: jsonMessage)
      do {
        try session.send(dataToSend, toPeers: session.connectedPeers, with: MCSessionSendDataMode.unreliable)
        completionHandler(true, nil)
      } catch {
        completionHandler(false, error)
      }
    } else {
      completionHandler(false, nil)
    }
  }

  // Make new session and invite user to it
  func getSession(for userId: String) -> MCSession? {
    if let session = sessions[userId] {
      return session
    }
    let session = MCSession(peer: myPeerId, securityIdentity: nil, encryptionPreference: .optional)
    session.delegate = self
    self.sessions[userId] = session
    return session
  }
}

// MARK: - MCSessionDelegate
extension MultipeerCommunicator: MCSessionDelegate {
  func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
    switch state {
    case MCSessionState.connected:
      print("Peer \(peerID.displayName) is connected to session: \(session)")
    case MCSessionState.connecting:
      print("Peer \(peerID.displayName) is connecting to session: \(session)")
    default:
      print("Peer \(peerID.displayName) is not connected to session: \(session)")
    }
  }

  func session(_ session: MCSession,
               didReceive data: Data,
               fromPeer peerID: MCPeerID) {
    guard let dataDictionary = NSKeyedUnarchiver.unarchiveObject(with: data) as? [String: String] else {
      Logger.write("Wrong data format received")
      return
    }
    delegate?.didReceiveMessage(text: dataDictionary["text"]!, fromUser: peerID.displayName, toUser: myPeerId.displayName)
  }

  func session(_ session: MCSession,
               didReceive stream: InputStream,
               withName streamName: String,
               fromPeer peerID: MCPeerID) {
    // For now user can't receive streams
  }

  func session(_ session: MCSession,
               didStartReceivingResourceWithName resourceName: String,
               fromPeer peerID: MCPeerID,
               with progress: Progress) {
  }

  func session(_ session: MCSession,
               didFinishReceivingResourceWithName resourceName: String,
               fromPeer peerID: MCPeerID,
               at localURL: URL?,
               withError error: Error?) {
  }
}

// MARK: - MCNearbyServiceBrowserDelegate
extension MultipeerCommunicator: MCNearbyServiceBrowserDelegate {
  func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String: String]?) {
    if let session = self.getSession(for: peerID.displayName),
      !session.connectedPeers.contains(peerID) && peerID.displayName != self.myPeerId.displayName {
      browser.invitePeer(peerID, to: session, withContext: nil, timeout: 30)
      self.delegate?.didFoundUser(userID: peerID.displayName, userName: info?["userName"] ?? "Unidentified user")
    }
  }

  func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
    self.sessions.removeValue(forKey: peerID.displayName)
    self.delegate?.didLostUser(userID: peerID.displayName)
  }

  func browser(_ browser: MCNearbyServiceBrowser, didNotStartBrowsingForPeers error: Error) {
    self.delegate?.failedToStartBrowsingForUsers(error: error)
  }

}

// MARK: - MCNearbyServiceAdvertiserDelegate
extension MultipeerCommunicator: MCNearbyServiceAdvertiserDelegate {
  func advertiser(_ advertiser: MCNearbyServiceAdvertiser,
                  didReceiveInvitationFromPeer peerID: MCPeerID,
                  withContext context: Data?,
                  invitationHandler: @escaping (Bool, MCSession?) -> Void) {
    if let session = getSession(for: peerID.displayName) {
      if session.connectedPeers.contains(peerID) {
        invitationHandler(false, nil)
      } else {
        invitationHandler(true, session)
        Logger.write("Connection is established")
      }
    }
  }
  func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didNotStartAdvertisingPeer error: Error) {
    self.online = false
    self.delegate?.failedToStartAdvertising(error: error)
  }

}
