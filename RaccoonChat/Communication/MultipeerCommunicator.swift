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
  // MARK: - Communicator interface
  func sendMessage(string: String, to userId: String, completionHandler: ((Bool, Error?) -> ())) {
    // TODO: implement
  }
  weak var delegate: CommunicatorDelegate?
  // TODO: implement
  var online: Bool = false
  var localPeerId: MCPeerID!
  
  // MARK: - Connection members
  private var session: MCSession!
  private var myPeerId: MCPeerID!
  private var advertiser: MCNearbyServiceAdvertiser!
  private var browser: MCNearbyServiceBrowser!
  
  // Var for all found peers
  var foundPeers = [MCPeerID]()
  var invitationHandler: ((Bool, MCSession)->Void)!
  
  let serviceType = "tinkoff-chat"
  
  // MARK: - Init
  override init() {
    super.init()
    
    myPeerId = MCPeerID(displayName: UIDevice.current.name)
    
    session = MCSession(peer: myPeerId)
    session.delegate = self
    
    browser = MCNearbyServiceBrowser(peer: myPeerId, serviceType: serviceType)
    browser.delegate = self
    
    advertiser = MCNearbyServiceAdvertiser(peer: myPeerId, discoveryInfo:  ["userName" : "This is me"], serviceType: serviceType)
    advertiser.delegate = self
    
    browser.startBrowsingForPeers()
    advertiser.startAdvertisingPeer()
  }
  
}

// MARK: - MCSessionDelegate
extension MultipeerCommunicator: MCSessionDelegate {
  func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
    // TODO: implement
  }
  
  func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
    // TODO: implement
  }
  
  func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
    // TODO: implement
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
    foundPeers.append(peerID)
    guard let discovery = info, let name = discovery["userName"] else {
      delegate?.didFoundUser(userID: peerID.displayName, userName: nil)
      return
    }
    delegate?.didFoundUser(userID: peerID.displayName, userName: name)
  }
  
  func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
    for (index, peer) in self.foundPeers.enumerated() {
      if peer == peerID {
        foundPeers.remove(at: index)
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
    // TODO: implement
  }
  func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didNotStartAdvertisingPeer error: Error) {
    delegate?.failedToStartAdvertising(error: error)
  }
  
}
