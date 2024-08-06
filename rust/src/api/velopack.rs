use velopack::*;
use anyhow::Result;

#[flutter_rust_bridge::frb(init)]
pub fn init_app() {
    flutter_rust_bridge::setup_default_user_utils();
    VelopackApp::build().run();
}

fn create_update_manager(url: &str) -> Result<UpdateManager<sources::HttpSource>> {
    let source = sources::HttpSource::new(url);
    UpdateManager::new(source, None)
}

pub fn is_update_available(url: String) -> Result<bool> {
    let um = create_update_manager(&url)?;
    let updates = um.check_for_updates()?;
    Ok(updates.is_some())
}

fn check_and_download_updates(url: &str) -> Result<Option<UpdateInfo>> {
    let um = create_update_manager(url)?;

    let updates = um.check_for_updates()?;
    if let Some(updates) = updates {
        um.download_updates(&updates, |progress| {
            println!("Download progress: {}%", progress);
        })?;
        Ok(Some(updates))
    } else {
        Ok(None)
    }
}

pub fn update_and_restart(url: String) -> Result<()> {
    if let Some(updates) = check_and_download_updates(&url)? {
        let um = create_update_manager(&url)?;
        um.apply_updates_and_restart(&updates, RestartArgs::None)?;
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
        um.wait_exit_then_apply_updates(&updates, silent, restart, RestartArgs::None)?;
    }
    Ok(())
}
