using System;
using Godot;

public partial class ActionItem : MenuItem
{
	private Action _action;

	public ActionItem(string name, Action action) : base(name)
	{
		_action = action;
	}

	public override void _Input(InputEvent @event)
	{
		if (!_selected)
		{
			return;
		}
		base._Input(@event);
		if (@event is InputEventKey key)
		{
			if (key.IsActionReleased("UIConfirm"))
			{
				_action.Invoke();
			}
		}
		else if (@event is InputEventMouseButton button)
		{
			if (button.ButtonIndex == MouseButton.Left && button.IsPressed())
			{
				_action.Invoke();
			}
		}
	}

	public override void _Ready()
	{
		base._Ready();
		AddChild(_label);
	}
}
