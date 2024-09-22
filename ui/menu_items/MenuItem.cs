using System;
using Godot;

public partial class MenuItem : MarginContainer
{
    public int Index;

    protected bool _selected;
    protected string _name;
    protected Label _label;

    public MenuItem(string name)
    {
        _selected = false;
        _name = name;
        _label = new Label();
        _label.Text = _name;
        MouseFilter = MouseFilterEnum.Stop;
    }

    public override void _Ready()
    {
        base._Ready();
        MouseEntered += FocusItem;
        MouseExited += DefocusItem;
        if (!_selected)
        {
            Modulate = Color.FromString("DARK_GRAY", Modulate);
        }
    }

    public void SetLabelSettings(LabelSettings ls)
    {
        _label.LabelSettings = ls;
    }

    public void Select()
    {
        _selected = true;
        Modulate = Color.FromString("WHITE", Modulate);
    }

    public void Deselect()
    {
        _selected = false;
        Modulate = Color.FromString("DARK_GRAY", Modulate);
    }

    private void FocusItem()
    {
        GetParent<MenuItems>().SwitchItem(Index);
    }

    private void DefocusItem()
    {
        GetParent<MenuItems>().SwitchItem(-1);
    }

}