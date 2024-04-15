using System;
using Godot;

[GlobalClass]
public partial class Armament : ShipModule
{
    [Export] private Vector2 damageRange = new Vector2(1.0f, 1.0f);
    [Export] private float baseAmmoCost = 1;
    [Export] private float chargeCapacity = 1;
    [Export] private float chargeMultiplier = 1.0f;
    [Export] private PackedScene ammoType;
    [Export] private Color color = new Color(1.0f, 1.0f, 1.0f);
}
