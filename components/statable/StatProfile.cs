using Godot;
using System;

public partial class StatProfile : Resource
{
    [Export] private Godot.Collections.Dictionary<String, Variant> stats = 
		new Godot.Collections.Dictionary<String, Variant>();
    
    public Godot.Collections.Array<String> getStatList()
    {
        return (Godot.Collections.Array<String>)stats.Keys;
    }

    public Variant getStatValue(String stat)
    {
        Variant statValue;
        stats.TryGetValue(stat, out statValue);
        return statValue;
    }
}
