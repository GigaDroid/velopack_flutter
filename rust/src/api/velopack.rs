use std::sync::mpsc;
use std::sync::OnceLock;

use anyhow::{bail, Result};
use flutter_rust_bridge::frb;
use velopack::{sources, Error, UpdateCheck, UpdateInfo, UpdateManager, VelopackApp};

use crate::frb_generated::StreamSink;

static VELOPACK_URL: OnceLock<String> = OnceLock::new();

#[frb(init)]
pub fn init_app() {
    flutter_rust_bridge::setup_default_user_utils();
    VelopackApp::build().run();
}

pub fn init_velopack(url: String) -> Result<()> {
    if let Err(url) = VELOPACK_URL.set(url) {
        if VELOPACK_URL.get() == Some(&url) {
            return Ok(());
        }

        bail!("Velopack is already initialized with a different URL");
    }

    Ok(())
}

fn get_update_manager() -> Result<UpdateManager, Error> {
    let url = VELOPACK_URL.get().ok_or(Error::Other(
        "Velopack not initialized. Call initializeVelopack() first.".into(),
    ))?;
    let source = sources::HttpSource::new(url);
    UpdateManager::new(source, None, None)
}

pub fn is_update_available() -> Result<bool> {
    let um = get_update_manager()?;
    let update_check = um.check_for_updates()?;
    Ok(matches!(update_check, UpdateCheck::UpdateAvailable(..)))
}

pub fn get_latest_update_info() -> Result<Option<UpdateInfo>> {
    let um = get_update_manager()?;
    let update_check = um.check_for_updates()?;
    return match update_check {
        UpdateCheck::UpdateAvailable(updates) => Ok(Some(*updates)),
        _ => Ok(None),
    };
}

pub fn current_version() -> Result<String> {
    let um = get_update_manager()?;
    Ok(um.get_current_version_as_string())
}

pub fn check_and_download_updates_with_progress(
    progress_sink: StreamSink<i16>,
) -> Result<Option<UpdateInfo>> {
    let um = get_update_manager()?;
    if let UpdateCheck::UpdateAvailable(updates) = um.check_for_updates().unwrap() {
        // Create a channel for progress messages
        let (sx, rx) = mpsc::channel();

        um.download_updates(&updates, Some(sx))?;

        std::thread::spawn(move || {
            while let Ok(progress) = rx.recv() {
                let _ = progress_sink.add(progress);
            }
        });

        Ok(Some(*updates))
    } else {
        Ok(None)
    }
}

fn check_and_download_updates() -> Result<Option<UpdateInfo>> {
    let um = get_update_manager()?;
    if let UpdateCheck::UpdateAvailable(updates) = um.check_for_updates().unwrap() {
        um.download_updates(&updates, None)?;
        Ok(Some(*updates))
    } else {
        Ok(None)
    }
}

pub fn update_and_restart() -> Result<()> {
    if let Some(updates) = check_and_download_updates()? {
        let um = get_update_manager()?;
        um.apply_updates_and_restart(&updates)?;
    }
    Ok(())
}

pub fn update_and_exit() -> Result<()> {
    if let Some(updates) = check_and_download_updates()? {
        let um = get_update_manager()?;
        um.apply_updates_and_exit(&updates)?;
    }
    Ok(())
}

pub fn wait_exit_then_update(silent: bool, restart: bool) -> Result<()> {
    if let Some(updates) = check_and_download_updates()? {
        let um = get_update_manager()?;
        um.wait_exit_then_apply_updates(&updates, silent, restart, [""])?;
    }
    Ok(())
}
