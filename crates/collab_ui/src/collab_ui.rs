mod collab_titlebar_item;
mod contact_finder;
mod contact_list;
mod contact_notification;
mod contacts_popover;
mod face_pile;
mod incoming_call_notification;
mod notifications;
mod project_shared_notification;
mod sharing_status_indicator;

use call::{ActiveCall, Room};
pub use collab_titlebar_item::{CollabTitlebarItem, ToggleContactsMenu};
use gpui::{actions, AppContext};
use std::sync::Arc;
use util::ResultExt;
use workspace::AppState;

actions!(
    collab,
    [
        ToggleScreenSharing,
        ToggleMute,
        ToggleDeafen,
        LeaveCall,
        ShareMicrophone
    ]
);

pub fn init(app_state: &Arc<AppState>, cx: &mut AppContext) {
    vcs_menu::init(cx);
    collab_titlebar_item::init(cx);
    contact_list::init(cx);
    contact_finder::init(cx);
    contacts_popover::init(cx);
    incoming_call_notification::init(&app_state, cx);
    project_shared_notification::init(&app_state, cx);
    sharing_status_indicator::init(cx);

    cx.add_global_action(toggle_screen_sharing);
    cx.add_global_action(toggle_mute);
    cx.add_global_action(toggle_deafen);
    cx.add_global_action(share_microphone);
}

pub fn toggle_screen_sharing(_: &ToggleScreenSharing, cx: &mut AppContext) {
    ActiveCall::global(cx).update(cx, |call, cx| {
        call.toggle_screen_sharing(cx);
    });
}

pub fn toggle_mute(_: &ToggleMute, cx: &mut AppContext) {
    if let Some(room) = ActiveCall::global(cx).read(cx).room().cloned() {
        room.update(cx, Room::toggle_mute)
            .map(|task| task.detach_and_log_err(cx))
            .log_err();
    }
}

pub fn toggle_deafen(_: &ToggleDeafen, cx: &mut AppContext) {
    if let Some(room) = ActiveCall::global(cx).read(cx).room().cloned() {
        room.update(cx, Room::toggle_deafen)
            .map(|task| task.detach_and_log_err(cx))
            .log_err();
    }
}

pub fn share_microphone(_: &ShareMicrophone, cx: &mut AppContext) {
    if let Some(room) = ActiveCall::global(cx).read(cx).room().cloned() {
        room.update(cx, Room::share_microphone)
            .detach_and_log_err(cx)
    }
}
