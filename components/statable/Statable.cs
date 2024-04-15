using Godot;
using System;
using System.Reflection.Metadata;

[GlobalClass]
public partial class Statable : Node
{
	public static int HP() => 0;

	[Export] public String readableName = "Generic";

	[Export] private Godot.Collections.Dictionary<String, Variant> stats = 
		new Godot.Collections.Dictionary<String, Variant>();

}
