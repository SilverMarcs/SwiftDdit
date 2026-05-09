import Foundation
import SwiftUI

@Observable class VoteActionViewModel {
    var likes: Bool?
    var upsCount: Int {
        didSet {
            formattedUpsCount = upsCount.formatted
        }
    }
    var formattedUpsCount: String
    
    @ObservationIgnored private let id: String
    @ObservationIgnored private let targetType: VoteTargetType

    init<T: Votable>(item: T, targetType: VoteTargetType) {
        self.likes = item.likes
        self.upsCount = item.ups
        self.formattedUpsCount = item.ups.formatted
        self.id = item.fullname
        self.targetType = targetType
    }

    func vote(action: RedditAPI.VoteAction) {
        hapticFeedback()
        let previousState = (likes: likes, count: upsCount)
        
        withAnimation {
            switch (action, likes) {
            case (.up, true):     // Remove upvote
                likes = nil
                upsCount -= 1
                
            case (.up, false):    // Change downvote to upvote
                likes = true
                upsCount += 2
                
            case (.up, nil):      // Add upvote
                likes = true
                upsCount += 1
                
            case (.down, true):   // Change upvote to downvote
                likes = false
                upsCount -= 2
                
            case (.down, false):  // Remove downvote
                likes = nil
                upsCount += 1
                
            case (.down, nil):    // Add downvote
                likes = false
                upsCount -= 1
                
            case (.none, _):
                break
            }
        }
        
        Task {
            let success = await (targetType == .post)
                ? RedditAPI.vote(action, id: id)
                : RedditAPI.voteComment(action, id: id)
                
            if success != true {
                // Revert on failure
                likes = previousState.likes
                upsCount = previousState.count
            }
        }
    }

    private func hapticFeedback() {
        #if os(iOS)
        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
        impactFeedback.prepare()
        impactFeedback.impactOccurred()
        #endif
    }
}

protocol Votable {
    var likes: Bool? { get }
    var ups: Int { get }
    var fullname: String { get }
}

enum VoteTargetType {
    case post
    case comment
}
