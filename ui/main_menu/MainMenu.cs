using Godot;
using System;


public partial class MainMenu : Control
{
	private MenuItems _menuItems;
	private GodotObject _saveManager;
	private GodotObject _sceneSwitcher;
	private GodotObject _globalSettings;


	// Called when the node enters the scene tree for the first time.
	public override void _Ready()
	{
		// Autoloads setup
		_saveManager = GetNode("/root/SaveManager");
		_sceneSwitcher = GetNode("/root/SceneSwitcher");
		_globalSettings = GetNode("/root/GlobalSettings");

		_saveManager.Set("player_loaded", false);
		_menuItems = GetNode<MenuItems>("%MenuItems");
		SwitchMenu(BuildMainMenu);
	}

	private void SwitchMenu(Action buildMenu)
	{
		// TODO: Add menu transition animations
		buildMenu();
	}

	private void BuildMainMenu()
	{
		_menuItems.ClearItems();
		if (SaveAvailable())
		{
			var continueItem = new ActionItem("Continue", ContinueGame);
			_menuItems.AddItem(continueItem);
		}
		var newGameItem = new ActionItem("New Game", StartNewGame);
		_menuItems.AddItem(newGameItem);
		var settingsItem = new ActionItem("Settings", () => SwitchMenu(BuildSettingsMenu));
		_menuItems.AddItem(settingsItem);
		var quitItem = new ActionItem("Quit", QuitGame);
		_menuItems.AddItem(quitItem);
	}

	private void BuildSettingsMenu()
	{
		_menuItems.ClearItems();

		float volume = (float) _globalSettings.Get("volume");
		var volumeSlider = new SliderItem("Volume", ChangeMasterVolume, 0, 100, volume);
		_menuItems.AddItem(volumeSlider);

		var mouseSensitivity = (float) _globalSettings.Get("mouse_sensitivity");
		var mouseSensitivitySlider = new SliderItem("Mouse Sensitivity", ChangeMouseSensitivity, 0.1f, 0.75f, mouseSensitivity);
		_menuItems.AddItem(mouseSensitivitySlider);

		var cameraBobbing = (float) _globalSettings.Get("bobbing_factor");
		var cameraBobbingSlider = new SliderItem("Camera Bobbing", ChangeCameraBobbing, 0, 1, cameraBobbing);
		_menuItems.AddItem(cameraBobbingSlider);

		var backItem = new ActionItem("Back", () => SwitchMenu(BuildMainMenu));
		_menuItems.AddItem(backItem);
	}

	private bool SaveAvailable()
	{
		string savePath = (string) _saveManager.Get("QS_PATH");
		if (ResourceLoader.Exists(savePath))
		{
			return (bool) _saveManager.Call("check_save_version");
		}
		return false;
	}

	private void ContinueGame()
	{
		_saveManager.Call("load");
		_sceneSwitcher.Call("menu_to_world");
	}

	private void StartNewGame()
	{
		_saveManager.Call("reset");
		_sceneSwitcher.Call("menu_to_world");
	}

	private void ChangeMasterVolume(float value)
	{
		int masterIdx = AudioServer.GetBusIndex("Master");
		float dbValue = 24 * Mathf.Log(value) / Mathf.Log(10) - 40;
		AudioServer.SetBusVolumeDb(masterIdx, dbValue);
		_globalSettings.Set("volume", value);
	}

	private void ChangeMouseSensitivity(float value)
	{
		_globalSettings.Set("mouse_sensitivity", value);
	}

	private void ChangeCameraBobbing(float value)
	{
		_globalSettings.Set("camera_bobbing", value);
	}

	public void QuitGame()
	{
		GetTree().Quit();
	}
}
