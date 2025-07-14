//
//  ThemeColors.swift
//  MiniAppLib
//
//  Created by w3bili on 2024/6/27.
//

import UIKit

public let KEY_BG_COLOR = "bg_color"
public let KEY_SECONDARY_BG_COLOR = "secondary_bg_color"
public let KEY_TEXT_COLOR = "text_color"
public let KEY_HINT_COLOR = "hint_color"
public let KEY_LINK_COLOR = "link_color"
public let KEY_BUTTON_COLOR = "button_color"
public let KEY_BUTTON_TEXT_COLOR = "button_text_color"
public let KEY_HEADER_BG_COLOR = "header_bg_color"
public let KEY_ACCENT_TEXT_COLOR = "accent_text_color"
public let KEY_SECTION_BG_COLOR = "section_bg_color"
public let KEY_SECTION_HEADER_TEXT_COLOR = "section_header_text_color"
public let KEY_SUBTITLE_TEXT_COLOR = "subtitle_text_color"
public let KEY_DESTRUCTIVE_TEXT_COLOR = "destructive_text_color"
public let KEY_SECTION_SEPARATOR_COLOR = "section_separator_color"

public let KEY_ITEM_CHECK_FILL_COLOR = "item_check_fill_color"
public let KEY_ITEM_CHECK_STROKE_COLOR = "item_check_stroke_color"
public let KEY_ITEM_CHECK_FOREGROUND_COLOR = "item_check_foreground_color"
public let KEY_ITEM_CHECK_DISCLOSURE_ARROW_COLOR = "item_check_disclosure_arrow_color"
public let KEY_ITEM_BLOCKS_BACKGROUND_COLOR = "item_blocks_background_color"
public let KEY_ITEM_SWITCH_FRAME_COLOR = "item_switch_frame_color"
public let KEY_ITEM_SWITCH_HANDLE_COLOR = "item_switch_handle_color"
public let KEY_ITEM_SWITCH_CONTENT_COLOR = "item_switch_content_color"
public let KEY_ITEM_SWITCH_POSITIVE_COLOR = "item_switch_positive_color"
public let KEY_ITEM_SWITCH_NEGATIVE_COLOR = "item_switch_negative_color"

public let KEY_TAB_BAR_BACKGROUND_COLOR = "tab_bar_background_color"
public let KEY_TAB_BAR_SEPARATOR_COLOR = "tab_bar_separator_color"
public let KEY_TAB_BAR_ICON_COLOR = "tab_bar_icon_color"
public let KEY_TAB_BAR_SELECTED_ICON_COLOR = "tab_bar_selected_icon_color"
public let KEY_TAB_BAR_TEXT_COLOR = "tab_bar_text_color"
public let KEY_TAB_BAR_SELECTED_TEXT_COLOR = "tab_bar_selected_text_color"
public let KEY_TAB_BAR_BADGE_BACKGROUND_COLOR = "tab_bar_badge_background_color"
public let KEY_TAB_BAR_BADGE_STROKE_COLOR = "tab_bar_badge_stroke_color"
public let KEY_TAB_BAR_BADGE_TEXT_COLOR = "tab_bar_badge_text_color"

public let KEY_NAVIGATION_BAR_BUTTON_COLOR = "navigation_bar_button_color"
public let KEY_NAVIGATION_BAR_DISABLED_BUTTON_COLOR = "navigation_bar_disabled_button_color"
public let KEY_NAVIGATION_BAR_PRIMARY_TEXT_COLOR = "navigation_bar_primary_text_color"
public let KEY_NAVIGATION_BAR_SECONDARY_TEXT_COLOR = "navigation_bar_secondary_text_color"
public let KEY_NAVIGATION_BAR_CONTROL_COLOR = "navigation_bar_control_color"
public let KEY_NAVIGATION_BAR_ACCENT_TEXT_COLOR = "navigation_bar_accent_text_color"
public let KEY_NAVIGATION_BAR_BLURRED_BACKGROUND_COLOR = "navigation_bar_blurred_background_color"
public let KEY_NAVIGATION_BAR_OPAQUE_BACKGROUND_COLOR = "navigation_bar_opaque_background_color"
public let KEY_NAVIGATION_BAR_SEPARATOR_COLOR = "navigation_bar_separator_color"
public let KEY_NAVIGATION_BAR_BADGE_BACKGROUND_COLOR = "navigation_bar_badge_background_color"
public let KEY_NAVIGATION_BAR_BADGE_STROKE_COLOR = "navigation_bar_badge_stroke_color"
public let KEY_NAVIGATION_BAR_BADGE_TEXT_COLOR = "navigation_bar_badge_text_color"
public let KEY_NAVIGATION_BAR_SEGMENTED_BACKGROUND_COLOR = "navigation_bar_segmented_background_color"
public let KEY_NAVIGATION_BAR_SEGMENTED_FOREGROUND_COLOR = "navigation_bar_segmented_foreground_color"
public let KEY_NAVIGATION_BAR_SEGMENTED_TEXT_COLOR = "navigation_bar_segmented_text_color"
public let KEY_NAVIGATION_BAR_SEGMENTED_DIVIDER_COLOR = "navigation_bar_segmented_divider_color"
public let KEY_NAVIGATION_BAR_CLEAR_BUTTON_BACKGROUND_COLOR = "navigation_bar_clear_button_background_color"
public let KEY_NAVIGATION_BAR_CLEAR_BUTTON_FOREGROUND_COLOR = "navigation_bar_clear_button_foreground_color"

public let KEY_ACTION_SHEET_DIM_COLOR = "action_sheet_dim_color"
public let KEY_ACTION_SHEET_OPAQUE_ITEM_BACKGROUND_COLOR = "action_sheet_opaque_item_background_color"
public let KEY_ACTION_SHEET_ITEM_BACKGROUND_COLOR = "action_sheet_item_background_color"
public let KEY_ACTION_SHEET_OPAQUE_ITEM_HIGHLIGHTED_BACKGROUND_COLOR = "action_sheet_opaque_item_highlighted_background_color"
public let KEY_ACTION_SHEET_ITEM_HIGHLIGHTED_BACKGROUND_COLOR = "action_sheet_item_highlighted_background_color"
public let KEY_ACTION_SHEET_OPAQUE_ITEM_SEPARATOR_COLOR = "action_sheet_opaque_item_separator_color"
public let KEY_ACTION_SHEET_STANDARD_ACTION_TEXT_COLOR = "action_sheet_standard_action_text_color"
public let KEY_ACTION_SHEET_DESTRUCTIVE_ACTION_TEXT_COLOR = "action_sheet_destructive_action_text_color"
public let KEY_ACTION_SHEET_DISABLED_ACTION_TEXT_COLOR = "action_sheet_disabled_action_text_color"
public let KEY_ACTION_SHEET_PRIMARY_TEXT_COLOR = "action_sheet_primary_text_color"
public let KEY_ACTION_SHEET_SECONDARY_TEXT_COLOR = "action_sheet_secondary_text_color"
public let KEY_ACTION_SHEET_CONTROL_ACCENT_COLOR = "action_sheet_control_accent_color"
public let KEY_ACTION_SHEET_INPUT_BACKGROUND_COLOR = "action_sheet_input_background_color"
public let KEY_ACTION_SHEET_INPUT_HOLLOW_BACKGROUND_COLOR = "action_sheet_input_hollow_background_color"
public let KEY_ACTION_SHEET_INPUT_BORDER_COLOR = "action_sheet_input_border_color"
public let KEY_ACTION_SHEET_INPUT_PLACEHOLDER_COLOR = "action_sheet_input_placeholder_color"
public let KEY_ACTION_SHEET_INPUT_TEXT_COLOR = "action_sheet_input_text_color"
public let KEY_ACTION_SHEET_INPUT_CLEAR_BUTTON_COLOR = "action_sheet_input_clear_button_color"
public let KEY_ACTION_SHEET_CHECK_CONTENT_COLOR = "action_sheet_check_content_color"

internal class ThemeColors {
    
    static let allColors: [String: (UIColor,UIColor)] =  [
        KEY_BG_COLOR: (UIColor(rgb: 0xffffff), UIColor(rgb: 0x000000)),
        KEY_SECONDARY_BG_COLOR: (UIColor(rgb: 0xefeff4), UIColor(rgb: 0x000000)),
        KEY_TEXT_COLOR: (UIColor(rgb: 0x000000), UIColor(rgb: 0xffffff)),
        KEY_HINT_COLOR: (UIColor(rgb: 0x8e8e93), UIColor(rgb: 0x98989e)),
        KEY_LINK_COLOR: (UIColor(rgb: 0x007aff), UIColor(rgb: 0xffffff)),
        KEY_BUTTON_COLOR: (UIColor(rgb: 0x007aff), UIColor(rgb: 0xffffff)),
        KEY_BUTTON_TEXT_COLOR: (UIColor(rgb: 0xffffff), UIColor(rgb: 0x000000)),
        KEY_HEADER_BG_COLOR: (UIColor(rgb: 0xf7f7f7).mixedWith(.white, alpha: 0.14), UIColor(rgb: 0x1d1d1d).mixedWith(UIColor(rgb: 0x000000), alpha: 0.1)),
        KEY_ACCENT_TEXT_COLOR: (UIColor(rgb: 0x007aff), UIColor(rgb: 0xffffff)),
        KEY_SECTION_BG_COLOR: (UIColor(rgb: 0xffffff), UIColor(rgb: 0x1c1c1d)),
        KEY_SECTION_HEADER_TEXT_COLOR: (UIColor(rgb: 0x6d6d72), UIColor(rgb: 0x8d8e93)),
        KEY_SUBTITLE_TEXT_COLOR: (UIColor(rgb: 0x8e8e93), UIColor(rgb: 0x98989e)),
        KEY_DESTRUCTIVE_TEXT_COLOR: (UIColor(rgb: 0xff3b30), UIColor(rgb: 0xeb5545)),
        KEY_SECTION_SEPARATOR_COLOR: (UIColor(rgb: 0xc8c7cc), UIColor(rgb: 0x545458, alpha: 0.55)),
        
        KEY_ITEM_CHECK_FILL_COLOR: (UIColor(rgb: 0x007aff), UIColor(rgb: 0xffffff)),
        KEY_ITEM_CHECK_STROKE_COLOR: (UIColor(rgb: 0xc7c7cc), UIColor(rgb: 0xffffff, alpha: 0.3)),
        KEY_ITEM_CHECK_FOREGROUND_COLOR: (UIColor(rgb: 0xffffff), UIColor(rgb: 0x000000)),
        KEY_ITEM_CHECK_DISCLOSURE_ARROW_COLOR: (UIColor(rgb: 0xbab9be), UIColor(rgb: 0xffffff, alpha: 0.28)),
        KEY_ITEM_BLOCKS_BACKGROUND_COLOR: (UIColor(rgb: 0xffffff), UIColor(rgb: 0x1c1c1d)),
        KEY_ITEM_SWITCH_FRAME_COLOR: (UIColor(rgb: 0xe9e9ea), UIColor(rgb: 0x39393d)),
        KEY_ITEM_SWITCH_HANDLE_COLOR: (UIColor(rgb: 0xffffff), UIColor(rgb: 0x121212)),
        KEY_ITEM_SWITCH_CONTENT_COLOR: (UIColor(rgb: 0x35c759), UIColor(rgb: 0x67ce67)),
        KEY_ITEM_SWITCH_POSITIVE_COLOR: (UIColor(rgb: 0x00c900), UIColor(rgb: 0x08a723)),
        KEY_ITEM_SWITCH_NEGATIVE_COLOR: (UIColor(rgb: 0xff3b30), UIColor(rgb: 0xeb5545)),
        
        KEY_TAB_BAR_BACKGROUND_COLOR: (UIColor(rgb: 0xf2f2f2, alpha: 0.9), UIColor(rgb: 0x1d1d1d, alpha: 0.9)),
        KEY_TAB_BAR_SEPARATOR_COLOR: (UIColor(rgb: 0xb2b2b2), UIColor(rgb: 0x545458, alpha: 0.55)),
        KEY_TAB_BAR_ICON_COLOR: (UIColor(rgb: 0x959595), UIColor(rgb: 0x828282)),
        KEY_TAB_BAR_SELECTED_ICON_COLOR: (UIColor(rgb: 0x007aff), UIColor(rgb: 0xffffff)),
        KEY_TAB_BAR_TEXT_COLOR: (UIColor(rgb: 0x959595), UIColor(rgb: 0x828282)),
        KEY_TAB_BAR_SELECTED_TEXT_COLOR: (UIColor(rgb: 0x007aff), UIColor(rgb: 0xffffff)),
        KEY_TAB_BAR_BADGE_BACKGROUND_COLOR: (UIColor(rgb: 0xff3b30), UIColor(rgb: 0xffffff)),
        KEY_TAB_BAR_BADGE_STROKE_COLOR: (UIColor(rgb: 0xff3b30), UIColor(rgb: 0x1c1c1d)),
        KEY_TAB_BAR_BADGE_TEXT_COLOR: (UIColor(rgb: 0xffffff), UIColor(rgb: 0x000000)),
        
        KEY_NAVIGATION_BAR_BUTTON_COLOR: (UIColor(rgb: 0x007aff), UIColor(rgb: 0xffffff)),
        KEY_NAVIGATION_BAR_DISABLED_BUTTON_COLOR: (UIColor(rgb: 0xd0d0d0), UIColor(rgb: 0x525252)),
        KEY_NAVIGATION_BAR_PRIMARY_TEXT_COLOR: (UIColor(rgb: 0x000000), UIColor(rgb: 0xffffff)),
        KEY_NAVIGATION_BAR_SECONDARY_TEXT_COLOR: (UIColor(rgb: 0x787878), UIColor(rgb: 0xffffff, alpha: 0.5)),
        KEY_NAVIGATION_BAR_CONTROL_COLOR: (UIColor(rgb: 0x7e8791), UIColor(rgb: 0x767676)),
        KEY_NAVIGATION_BAR_ACCENT_TEXT_COLOR: (UIColor(rgb: 0x007aff), UIColor(rgb: 0xffffff)),
        KEY_NAVIGATION_BAR_BLURRED_BACKGROUND_COLOR: (UIColor(rgb: 0xf2f2f2, alpha: 0.9), UIColor(rgb: 0x1d1d1d, alpha: 0.9)),
        KEY_NAVIGATION_BAR_OPAQUE_BACKGROUND_COLOR: (UIColor(rgb: 0xf7f7f7).mixedWith(.white, alpha: 0.14), UIColor(rgb: 0x1d1d1d).mixedWith(UIColor(rgb: 0x000000), alpha: 0.1)),
        KEY_NAVIGATION_BAR_SEPARATOR_COLOR: (UIColor(rgb: 0xc8c7cc), UIColor(rgb: 0x545458, alpha: 0.55)),
        KEY_NAVIGATION_BAR_BADGE_BACKGROUND_COLOR: (UIColor(rgb: 0xff3b30), UIColor(rgb: 0xffffff)),
        KEY_NAVIGATION_BAR_BADGE_STROKE_COLOR: (UIColor(rgb: 0xff3b30), UIColor(rgb: 0x1c1c1d)),
        KEY_NAVIGATION_BAR_BADGE_TEXT_COLOR: (UIColor(rgb: 0xffffff), UIColor(rgb: 0x000000)),
        KEY_NAVIGATION_BAR_SEGMENTED_BACKGROUND_COLOR: (UIColor(rgb: 0x000000, alpha: 0.06), UIColor(rgb: 0x3a3b3d)),
        KEY_NAVIGATION_BAR_SEGMENTED_FOREGROUND_COLOR: (UIColor(rgb: 0xf7f7f7), UIColor(rgb: 0x6f7075)),
        KEY_NAVIGATION_BAR_SEGMENTED_TEXT_COLOR: (UIColor(rgb: 0x000000), UIColor(rgb: 0xffffff)),
        KEY_NAVIGATION_BAR_SEGMENTED_DIVIDER_COLOR: (UIColor(rgb: 0xd6d6dc), UIColor(rgb: 0x505155)),
        KEY_NAVIGATION_BAR_CLEAR_BUTTON_BACKGROUND_COLOR: (UIColor(rgb: 0xE3E3E3, alpha: 0.78), UIColor(rgb: 0xffffff, alpha: 0.1)),
        KEY_NAVIGATION_BAR_CLEAR_BUTTON_FOREGROUND_COLOR: (UIColor(rgb: 0x7f7f7f), UIColor(rgb: 0xffffff)),
        
        KEY_ACTION_SHEET_DIM_COLOR: (UIColor(white: 0.0, alpha: 0.4), UIColor(white: 0.0, alpha: 0.5)),
        KEY_ACTION_SHEET_OPAQUE_ITEM_BACKGROUND_COLOR: (UIColor(rgb: 0xffffff), UIColor(rgb: 0x1c1c1d)),
        KEY_ACTION_SHEET_ITEM_BACKGROUND_COLOR: (UIColor(white: 1.0, alpha: 0.8), UIColor(rgb: 0x1c1c1d, alpha: 0.8)),
        KEY_ACTION_SHEET_OPAQUE_ITEM_HIGHLIGHTED_BACKGROUND_COLOR: (UIColor(white: 0.9, alpha: 1.0), UIColor(white: 0.0, alpha: 1.0)),
        KEY_ACTION_SHEET_ITEM_HIGHLIGHTED_BACKGROUND_COLOR: (UIColor(white: 0.9, alpha: 0.7), UIColor(rgb: 0x000000, alpha: 0.5)),
        KEY_ACTION_SHEET_OPAQUE_ITEM_SEPARATOR_COLOR: (UIColor(white: 0.9, alpha: 1.0), UIColor(rgb: 0x545458, alpha: 0.55)),
        KEY_ACTION_SHEET_STANDARD_ACTION_TEXT_COLOR: (UIColor(rgb: 0x007aff), UIColor(rgb: 0xffffff)),
        KEY_ACTION_SHEET_DESTRUCTIVE_ACTION_TEXT_COLOR: (UIColor(rgb: 0xff3b30), UIColor(rgb: 0xeb5545)),
        KEY_ACTION_SHEET_DISABLED_ACTION_TEXT_COLOR: (UIColor(rgb: 0xb3b3b3), UIColor(rgb: 0x4d4d4d)),
        KEY_ACTION_SHEET_PRIMARY_TEXT_COLOR: (UIColor(rgb: 0x000000), UIColor(rgb: 0xffffff)),
        KEY_ACTION_SHEET_SECONDARY_TEXT_COLOR: (UIColor(rgb: 0x8e8e93), UIColor(rgb: 0x5e5e5e)),
        KEY_ACTION_SHEET_CONTROL_ACCENT_COLOR: (UIColor(rgb: 0x007aff), UIColor(rgb: 0xffffff)),
        KEY_ACTION_SHEET_INPUT_BACKGROUND_COLOR: (UIColor(rgb: 0xe9e9e9), UIColor(rgb: 0x0f0f0f)),
        KEY_ACTION_SHEET_INPUT_HOLLOW_BACKGROUND_COLOR: (UIColor(rgb: 0xffffff), UIColor(rgb: 0x0f0f0f)),
        KEY_ACTION_SHEET_INPUT_BORDER_COLOR: (UIColor(rgb: 0xe4e4e6), UIColor(rgb: 0x0f0f0f)),
        KEY_ACTION_SHEET_INPUT_PLACEHOLDER_COLOR: (UIColor(rgb: 0x8e8d92), UIColor(rgb: 0x8f8f8f)),
        KEY_ACTION_SHEET_INPUT_TEXT_COLOR: (UIColor(rgb: 0x000000), UIColor(rgb: 0xffffff)),
        KEY_ACTION_SHEET_INPUT_CLEAR_BUTTON_COLOR: (UIColor(rgb: 0x9e9ea1), UIColor(rgb: 0x8f8f8f)),
        KEY_ACTION_SHEET_CHECK_CONTENT_COLOR: (UIColor(rgb: 0xffffff), UIColor(rgb: 0x000000))
    ]
}


