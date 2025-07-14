import Foundation

internal struct Namespaces {
    internal struct Message {
        public static let Cloud: Int32 = 0
        public static let Local: Int32 = 1
        public static let SecretIncoming: Int32 = 2
        public static let ScheduledCloud: Int32 = 3
        public static let ScheduledLocal: Int32 = 4
        public static let QuickReplyCloud: Int32 = 5
        public static let QuickReplyLocal: Int32 = 6
        
        public static let allScheduled: Set<Int32> = Set([Namespaces.Message.ScheduledCloud, Namespaces.Message.ScheduledLocal])
        public static let allQuickReply: Set<Int32> = Set([Namespaces.Message.QuickReplyCloud, Namespaces.Message.QuickReplyLocal])
        public static let allNonRegular: Set<Int32> = Set([Namespaces.Message.ScheduledCloud, Namespaces.Message.ScheduledLocal, Namespaces.Message.QuickReplyCloud, Namespaces.Message.QuickReplyLocal])
    }
    
    internal struct Media {
        public static let CloudImage: Int32 = 0
        public static let CloudAudio: Int32 = 2
        public static let CloudContact: Int32 = 3
        public static let CloudMap: Int32 = 4
        public static let CloudFile: Int32 = 5
        public static let CloudWebpage: Int32 = 6
        public static let LocalImage: Int32 = 7
        public static let LocalFile: Int32 = 8
        public static let CloudSecretImage: Int32 = 9
        public static let CloudSecretFile: Int32 = 10
        public static let CloudGame: Int32 = 11
        public static let CloudInvoice: Int32 = 12
        public static let LocalWebpage: Int32 = 13
        public static let LocalPoll: Int32 = 14
        public static let CloudPoll: Int32 = 15
    }
    
    internal struct ItemCollection {
        public static let CloudStickerPacks: Int32 = 0
        public static let CloudMaskPacks: Int32 = 1
        public static let EmojiKeywords: Int32 = 2
        public static let CloudAnimatedEmoji: Int32 = 3
        public static let CloudDice: Int32 = 4
        public static let CloudAnimatedEmojiAnimations: Int32 = 5
        public static let CloudAnimatedEmojiReactions: Int32 = 6
        public static let CloudPremiumGifts: Int32 = 7
        public static let CloudEmojiPacks: Int32 = 8
        public static let CloudEmojiGenericAnimations: Int32 = 9
        public static let CloudIconStatusEmoji: Int32 = 10
        public static let CloudIconTopicEmoji: Int32 = 11
        public static let CloudIconChannelStatusEmoji: Int32 = 12
    }
    
    internal struct OrderedItemList {
        public static let CloudRecentStickers: Int32 = 0
        public static let CloudRecentGifs: Int32 = 1
        public static let RecentlySearchedPeerIds: Int32 = 2
        public static let CloudRecentInlineBots: Int32 = 3
        public static let CloudFeaturedStickerPacks: Int32 = 4
        public static let CloudArchivedStickerPacks: Int32 = 5
        public static let CloudWallpapers: Int32 = 6
        public static let CloudSavedStickers: Int32 = 7
        public static let RecentlyUsedHashtags: Int32 = 8
        public static let CloudThemes: Int32 = 9
        public static let CloudGreetingStickers: Int32 = 10
        public static let RecentDownloads: Int32 = 11
        public static let PremiumStickers: Int32 = 12
        public static let CloudPremiumStickers: Int32 = 13
        public static let LocalRecentEmoji: Int32 = 14
        public static let CloudFeaturedEmojiPacks: Int32 = 15
        public static let CloudAllPremiumStickers: Int32 = 16
        public static let CloudRecentStatusEmoji: Int32 = 17
        public static let CloudFeaturedStatusEmoji: Int32 = 18
        public static let CloudRecentReactions: Int32 = 19
        public static let CloudTopReactions: Int32 = 20
        public static let CloudEmojiCategories: Int32 = 21
        public static let CloudEmojiStatusCategories: Int32 = 22
        public static let CloudFeaturedProfilePhotoEmoji: Int32 = 23
        public static let CloudFeaturedGroupPhotoEmoji: Int32 = 24
        public static let NewSessionReviews: Int32 = 25
        public static let CloudFeaturedBackgroundIconEmoji: Int32 = 26
        public static let CloudFeaturedChannelStatusEmoji: Int32 = 27
        public static let CloudDisabledChannelStatusEmoji: Int32 = 28
        public static let CloudDefaultTagReactions: Int32 = 29
    }
    
    internal struct CachedItemCollection {
        public static let resolvedByNamePeers: Int8 = 0
        public static let cachedTwoStepToken: Int8 = 1
        public static let cachedStickerPacks: Int8 = 2
        public static let cachedAvailableLocalizations: Int8 = 3
        public static let cachedSentMediaReferences: Int8 = 4
        public static let cachedStickerQueryResults: Int8 = 5
        public static let cachedSecureIdConfiguration: Int8 = 6
        public static let cachedWallpapersConfiguration: Int8 = 7
        public static let cachedThemesConfiguration: Int8 = 8
        public static let cachedPollResults: Int8 = 9
        public static let cachedContextResults: Int8 = 10
        public static let proximityNotificationStoredState: Int8 = 11
        public static let cachedGroupCallDisplayAsPeers: Int8 = 14
        public static let cachedAdMessageStates: Int8 = 15
        public static let cachedPeerInvitationImporters: Int8 = 16
        public static let cachedPeerExportedInvitations: Int8 = 17
        public static let cachedSendAsPeers: Int8 = 18
        public static let availableReactions: Int8 = 19
        public static let resolvedByPhonePeers: Int8 = 20
        public static let notificationSoundList: Int8 = 22
        public static let attachMenuBots: Int8 = 23
        public static let featuredStickersConfiguration: Int8 = 24
        public static let emojiSearchCategories: Int8 = 25
        public static let cachedEmojiQueryResults: Int8 = 26
        public static let cachedPeerStoryListHeads: Int8 = 27
        public static let displayedStoryNotifications: Int8 = 28
        public static let storySendAsPeerIds: Int8 = 29
        public static let cachedChannelBoosts: Int8 = 31
        public static let displayedMessageNotifications: Int8 = 32
        public static let recommendedChannels: Int8 = 33
        public static let peerColorOptions: Int8 = 34
        public static let savedMessageTags: Int8 = 35
        public static let applicationIcons: Int8 = 36
    }
}

internal struct LegacyPeerSummaryCounterTags: OptionSet, Sequence, Hashable {
    public var rawValue: Int32
    
    public init(rawValue: Int32) {
        self.rawValue = rawValue
    }
    
    public static let regularChatsAndPrivateGroups = LegacyPeerSummaryCounterTags(rawValue: 1 << 0)
    public static let publicGroups = LegacyPeerSummaryCounterTags(rawValue: 1 << 1)
    public static let channels = LegacyPeerSummaryCounterTags(rawValue: 1 << 2)
    
    public func makeIterator() -> AnyIterator<LegacyPeerSummaryCounterTags> {
        var index = 0
        return AnyIterator { () -> LegacyPeerSummaryCounterTags? in
            while index < 31 {
                let currentTags = self.rawValue >> UInt32(index)
                let tag = LegacyPeerSummaryCounterTags(rawValue: 1 << UInt32(index))
                index += 1
                if currentTags == 0 {
                    break
                }
                
                if (currentTags & 1) != 0 {
                    return tag
                }
            }
            return nil
        }
    }
}

private enum PreferencesKeyValues: Int32 {
    case globalNotifications = 0
    case suggestedLocalization = 3
    case limitsConfiguration = 4
    case contentPrivacySettings = 8
    case networkSettings = 9
    case remoteStorageConfiguration = 10
    case voipConfiguration = 11
    case appChangelogState = 12
    case localizationListState = 13
    case appConfiguration = 14
    case searchBotsConfiguration = 15
    case contactsSettings = 16
    case contentSettings = 19
    case chatListFilters = 20
    case peersNearby = 21
    case chatListFiltersFeaturedState = 22
    case secretChatSettings = 23
    case reactionSettings = 24
    case premiumPromo = 26
    case globalMessageAutoremoveTimeoutSettings = 27
    case accountSpecificCacheStorageSettings = 28
    case linksConfiguration = 29
    case chatListFilterUpdates = 30
    case globalPrivacySettings = 31
    case storiesConfiguration = 32
    case audioTranscriptionTrialState = 33
    case didCacheSavedMessageTagsPrefix = 34
    case displaySavedChatsAsTopics = 35
    case shortcutMessages = 37
    case timezoneList = 38
    case botBiometricsState = 39
    case businessLinks = 40
}

internal func applicationSpecificPreferencesKey(_ value: Int32) -> ValueBoxKey {
    let key = ValueBoxKey(length: 4)
    key.setInt32(0, value: value + 1000)
    return key
}

internal func applicationSpecificSharedDataKey(_ value: Int32) -> ValueBoxKey {
    let key = ValueBoxKey(length: 4)
    key.setInt32(0, value: value + 1000)
    return key
}

internal struct PreferencesKeys {
    public static let globalNotifications: ValueBoxKey = {
        let key = ValueBoxKey(length: 4)
        key.setInt32(0, value: PreferencesKeyValues.globalNotifications.rawValue)
        return key
    }()
    
    public static let suggestedLocalization: ValueBoxKey = {
        let key = ValueBoxKey(length: 4)
        key.setInt32(0, value: PreferencesKeyValues.suggestedLocalization.rawValue)
        return key
    }()
    
    public static let limitsConfiguration: ValueBoxKey = {
        let key = ValueBoxKey(length: 4)
        key.setInt32(0, value: PreferencesKeyValues.limitsConfiguration.rawValue)
        return key
    }()
    
    public static let contentPrivacySettings: ValueBoxKey = {
        let key = ValueBoxKey(length: 4)
        key.setInt32(0, value: PreferencesKeyValues.contentPrivacySettings.rawValue)
        return key
    }()
    
    public static let networkSettings: ValueBoxKey = {
        let key = ValueBoxKey(length: 4)
        key.setInt32(0, value: PreferencesKeyValues.networkSettings.rawValue)
        return key
    }()
    
    public static let remoteStorageConfiguration: ValueBoxKey = {
        let key = ValueBoxKey(length: 4)
        key.setInt32(0, value: PreferencesKeyValues.remoteStorageConfiguration.rawValue)
        return key
    }()
    
    public static let voipConfiguration: ValueBoxKey = {
        let key = ValueBoxKey(length: 4)
        key.setInt32(0, value: PreferencesKeyValues.voipConfiguration.rawValue)
        return key
    }()
    
    public static let appChangelogState: ValueBoxKey = {
        let key = ValueBoxKey(length: 4)
        key.setInt32(0, value: PreferencesKeyValues.appChangelogState.rawValue)
        return key
    }()
    
    public static let localizationListState: ValueBoxKey = {
        let key = ValueBoxKey(length: 4)
        key.setInt32(0, value: PreferencesKeyValues.localizationListState.rawValue)
        return key
    }()
    
    public static let appConfiguration: ValueBoxKey = {
        let key = ValueBoxKey(length: 4)
        key.setInt32(0, value: PreferencesKeyValues.appConfiguration.rawValue)
        return key
    }()
    
    public static let searchBotsConfiguration: ValueBoxKey = {
        let key = ValueBoxKey(length: 4)
        key.setInt32(0, value: PreferencesKeyValues.searchBotsConfiguration.rawValue)
        return key
    }()
    
    public static let contactsSettings: ValueBoxKey = {
        let key = ValueBoxKey(length: 4)
        key.setInt32(0, value: PreferencesKeyValues.contactsSettings.rawValue)
        return key
    }()
    
    public static let secretChatSettings: ValueBoxKey = {
        let key = ValueBoxKey(length: 4)
        key.setInt32(0, value: PreferencesKeyValues.secretChatSettings.rawValue)
        return key
    }()
        
    public static let contentSettings: ValueBoxKey = {
        let key = ValueBoxKey(length: 4)
        key.setInt32(0, value: PreferencesKeyValues.contentSettings.rawValue)
        return key
    }()
    
    public static let chatListFilters: ValueBoxKey = {
        let key = ValueBoxKey(length: 4)
        key.setInt32(0, value: PreferencesKeyValues.chatListFilters.rawValue)
        return key
    }()
    
    public static let peersNearby: ValueBoxKey = {
        let key = ValueBoxKey(length: 4)
        key.setInt32(0, value: PreferencesKeyValues.peersNearby.rawValue)
        return key
    }()
    
    public static let chatListFiltersFeaturedState: ValueBoxKey = {
        let key = ValueBoxKey(length: 4)
        key.setInt32(0, value: PreferencesKeyValues.chatListFiltersFeaturedState.rawValue)
        return key
    }()
    
    public static let reactionSettings: ValueBoxKey = {
        let key = ValueBoxKey(length: 4)
        key.setInt32(0, value: PreferencesKeyValues.reactionSettings.rawValue)
        return key
    }()
    
    public static let premiumPromo: ValueBoxKey = {
        let key = ValueBoxKey(length: 4)
        key.setInt32(0, value: PreferencesKeyValues.premiumPromo.rawValue)
        return key
    }()
    
    public static let globalMessageAutoremoveTimeoutSettings: ValueBoxKey = {
        let key = ValueBoxKey(length: 4)
        key.setInt32(0, value: PreferencesKeyValues.globalMessageAutoremoveTimeoutSettings.rawValue)
        return key
    }()
    
    public static let accountSpecificCacheStorageSettings: ValueBoxKey = {
        let key = ValueBoxKey(length: 4)
        key.setInt32(0, value: PreferencesKeyValues.accountSpecificCacheStorageSettings.rawValue)
        return key
    }()
    
    public static let linksConfiguration: ValueBoxKey = {
        let key = ValueBoxKey(length: 4)
        key.setInt32(0, value: PreferencesKeyValues.linksConfiguration.rawValue)
        return key
    }()
    
    public static let chatListFilterUpdates: ValueBoxKey = {
        let key = ValueBoxKey(length: 4)
        key.setInt32(0, value: PreferencesKeyValues.chatListFilterUpdates.rawValue)
        return key
    }()
    
    public static let globalPrivacySettings: ValueBoxKey = {
        let key = ValueBoxKey(length: 4)
        key.setInt32(0, value: PreferencesKeyValues.globalPrivacySettings.rawValue)
        return key
    }()
    
    public static let storiesConfiguration: ValueBoxKey = {
        let key = ValueBoxKey(length: 4)
        key.setInt32(0, value: PreferencesKeyValues.storiesConfiguration.rawValue)
        return key
    }()
    
    public static let audioTranscriptionTrialState: ValueBoxKey = {
        let key = ValueBoxKey(length: 4)
        key.setInt32(0, value: PreferencesKeyValues.audioTranscriptionTrialState.rawValue)
        return key
    }()
    
    public static func didCacheSavedMessageTags(threadId: Int64?) -> ValueBoxKey {
        let key = ValueBoxKey(length: 4 + 8)
        key.setInt32(0, value: PreferencesKeyValues.didCacheSavedMessageTagsPrefix.rawValue)
        key.setInt64(4, value: threadId ?? 0)
        return key
    }
    
    public static func displaySavedChatsAsTopics() -> ValueBoxKey {
        let key = ValueBoxKey(length: 4)
        key.setInt32(0, value: PreferencesKeyValues.displaySavedChatsAsTopics.rawValue)
        return key
    }
    
    public static func shortcutMessages() -> ValueBoxKey {
        let key = ValueBoxKey(length: 4)
        key.setInt32(0, value: PreferencesKeyValues.shortcutMessages.rawValue)
        return key
    }
    
    public static func timezoneList() -> ValueBoxKey {
        let key = ValueBoxKey(length: 4)
        key.setInt32(0, value: PreferencesKeyValues.timezoneList.rawValue)
        return key
    }
    
    static func botBiometricsStatePrefix() -> ValueBoxKey {
        let key = ValueBoxKey(length: 4)
        key.setInt32(0, value: PreferencesKeyValues.botBiometricsState.rawValue)
        return key
    }
    
    public static func businessLinks() -> ValueBoxKey {
        let key = ValueBoxKey(length: 4)
        key.setInt32(0, value: PreferencesKeyValues.businessLinks.rawValue)
        return key
    }
}

private enum SharedDataKeyValues: Int32 {
    case loggingSettings = 0
    case cacheStorageSettings = 2
    case localizationSettings = 3
    case proxySettings = 4
    case autodownloadSettings = 5
    case themeSettings = 6
    case countriesList = 7
    case wallapersState = 8
    case chatThemes = 10
}

internal struct SharedDataKeys {
    public static let loggingSettings: ValueBoxKey = {
        let key = ValueBoxKey(length: 4)
        key.setInt32(0, value: SharedDataKeyValues.loggingSettings.rawValue)
        return key
    }()
    
    public static let cacheStorageSettings: ValueBoxKey = {
        let key = ValueBoxKey(length: 4)
        key.setInt32(0, value: SharedDataKeyValues.cacheStorageSettings.rawValue)
        return key
    }()
    
    public static let localizationSettings: ValueBoxKey = {
        let key = ValueBoxKey(length: 4)
        key.setInt32(0, value: SharedDataKeyValues.localizationSettings.rawValue)
        return key
    }()
    
    public static let proxySettings: ValueBoxKey = {
        let key = ValueBoxKey(length: 4)
        key.setInt32(0, value: SharedDataKeyValues.proxySettings.rawValue)
        return key
    }()
    
    public static let autodownloadSettings: ValueBoxKey = {
        let key = ValueBoxKey(length: 4)
        key.setInt32(0, value: SharedDataKeyValues.autodownloadSettings.rawValue)
        return key
    }()
    
    public static let themeSettings: ValueBoxKey = {
        let key = ValueBoxKey(length: 4)
        key.setInt32(0, value: SharedDataKeyValues.themeSettings.rawValue)
        return key
    }()
    
    public static let countriesList: ValueBoxKey = {
        let key = ValueBoxKey(length: 4)
        key.setInt32(0, value: SharedDataKeyValues.countriesList.rawValue)
        return key
    }()

    public static let wallapersState: ValueBoxKey = {
        let key = ValueBoxKey(length: 4)
        key.setInt32(0, value: SharedDataKeyValues.wallapersState.rawValue)
        return key
    }()
    
    public static let chatThemes: ValueBoxKey = {
        let key = ValueBoxKey(length: 4)
        key.setInt32(0, value: SharedDataKeyValues.chatThemes.rawValue)
        return key
    }()
}

internal func applicationSpecificItemCacheCollectionId(_ value: Int8) -> Int8 {
    return 64 + value
}

internal func applicationSpecificOrderedItemListCollectionId(_ value: Int32) -> Int32 {
    return 1000 + value
}
