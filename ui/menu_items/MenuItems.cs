using Godot;
using System.Collections.Generic;
using System.Reflection.Metadata;

public partial class MenuItems : VBoxContainer
{
	[Export]
	public float ItemSpacing { get; set; }
	[Export]
	public LabelSettings LabelSettings { get; set; }

	private int _selectedIndex = -1;
	private List<MenuItem> _menuItems;

	public MenuItems()
	{
		_menuItems = new List<MenuItem>();
	}

    public override void _Input(InputEvent @event)
    {
        base._Input(@event);
		if (@event is InputEventKey key)
		{
			if (key.IsActionReleased("UIUp"))
			{
				PreviousItem();	
			}
			else if (key.IsActionReleased("UIDown"))
			{
				NextItem();
			}
		}
    }

    public void AddItem(MenuItem item)
	{
		if (_menuItems.Count != 0)
		{
			var spacing = new Control();
			spacing.MouseFilter = MouseFilterEnum.Ignore;
			spacing.CustomMinimumSize = new Vector2(0, ItemSpacing);
			AddChild(spacing);
		}
		else
		{
			_selectedIndex = 0;
			item.Select();
		}

		item.SetLabelSettings(LabelSettings);
		item.Index = _menuItems.Count;
		AddChild(item);
		_menuItems.Add(item);
	}

	public void NextItem()
	{
		if (_selectedIndex == -1)
		{
			_selectedIndex = 0;
		}
		else
		{
			_menuItems[_selectedIndex].Deselect();
			_selectedIndex = (_selectedIndex + 1) % _menuItems.Count;
		}
		_menuItems[_selectedIndex].Select();
	}

	public void PreviousItem()
	{
		if (_selectedIndex == -1)
		{
			_selectedIndex = 0;
		}
		else
		{
			_menuItems[_selectedIndex].Deselect();
			_selectedIndex = (_selectedIndex - 1 + _menuItems.Count) % _menuItems.Count;
		}
		_menuItems[_selectedIndex].Select();
	}

	public void SwitchItem(int index)
	{
		if (_selectedIndex != -1)
		{
			_menuItems[_selectedIndex].Deselect();
		}
		_selectedIndex = index;
		if (index != -1)
		{
			_menuItems[_selectedIndex].Select();
		}
	}

	public void ClearItems()
	{
		foreach (Node child in GetChildren())
		{
			child.QueueFree();
		}
		_menuItems.Clear();
		_selectedIndex = -1;
	}
}
