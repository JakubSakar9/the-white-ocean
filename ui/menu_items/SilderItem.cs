using Godot;
using System;

public partial class SliderItem : MenuItem
{
    private Action<float> _action;
    private Slider _slider;

    const int SLIDER_WIDTH = 200;
    const int SLIDER_SPACING = 16;
    
    public SliderItem(string name, Action<float> action, float minValue, float maxValue, float value) : base(name)
    {
        _action = action;
        _slider = new HSlider();
        _slider.MinValue = minValue;
        _slider.MaxValue = maxValue;
        _slider.Step = (maxValue - minValue) / 100.0;
        _slider.Value = value;
        _slider.ValueChanged += OnValueChanged;
        OnValueChanged(_slider.Value);
    }

    public override void _Ready()
    {
        base._Ready();

        _slider.CustomMinimumSize = new Vector2(SLIDER_WIDTH, 0);
        _slider.SetAnchorsPreset(LayoutPreset.Center);

        var sliderHCntr = new HBoxContainer();
        AddChild(sliderHCntr);
        sliderHCntr.AddChild(_label);
        var sliderSpacing = new Control();
        sliderSpacing.CustomMinimumSize = new Vector2(SLIDER_SPACING, 0);
        sliderHCntr.AddChild(sliderSpacing);
        var sliderCenterCntr = new CenterContainer();
        sliderCenterCntr.AddChild(_slider);
        sliderCenterCntr.SetAnchorsPreset(LayoutPreset.FullRect);
        sliderHCntr.AddChild(sliderCenterCntr);
    }

    private void OnValueChanged(double value)
    {
        _action.Invoke((float) value);
    }
}