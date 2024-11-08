use velopack::*;
use anyhow::Result;

#[flutter_rust_bridge::frb(init)]
pub fn init_app() {
    flutter_rust_bridge::setup_default_user_utils();
    VelopackApp::build().run();
}

fn create_update_manager(url: &str) -> Result<UpdateManager, Error> {
    let source = sources::HttpSource::new(url);
    UpdateManager::new(source, None, None)
}

pub fn is_update_available(url: String) -> Result<bool> {
    let um = create_update_manager(&url)?;
    let update_check = um.check_for_updates()?;
    Ok(matches!(update_check, UpdateCheck::UpdateAvailable(..)))
}

fn check_and_download_updates(url: &str) -> Result<Option<UpdateInfo>> {
    let um = create_update_manager(url)?;
    if let UpdateCheck::UpdateAvailable(updates) = um.check_for_updates().unwrap() {
        um.download_updates(&updates, None)?;
        Ok(Some(updates))
    } else {
        Ok(None)
    }
}

pub fn update_and_restart(url: String) -> Result<()> {
    if let Some(updates) = check_and_download_updates(&url)? {
        let um = create_update_manager(&url)?;
        um.apply_updates_and_restart(&updates)?;
    }
    Ok(())
}

pub fn update_and_exit(url: String) -> Result<()> {
    if let Some(updates) = check_and_download_updates(&url)? {
        let um = create_update_manager(&url)?;
        um.apply_updates_and_exit(&updates)?;
    }
    Ok(())
}

pub fn wait_exit_then_update(url: String, silent: bool, restart: bool) -> Result<()> {
    if let Some(updates) = check_and_download_updates(&url)? {
        let um = create_update_manager(&url)?;
        um.wait_exit_then_apply_updates(&updates, silent, restart,[""])?;
    }
    Ok(())
}
