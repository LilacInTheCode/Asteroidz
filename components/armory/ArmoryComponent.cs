using System;
using Godot;

[GlobalClass]
public partial class ArmoryComponent : Node
{
	[Export(PropertyHint.Dir)] private String armoryDirectory;
	[Export] private String playerHandle = "PLR";
	[Export] private int livesRemaining = 0;
	[Export] private float baseHP = 1;
	private float currentHP;
	[Export] float baseEnergy = 1;
	private float currentEnergy;

	[Export] private Godot.Collections.Array<ShipModule> equipment =
		new Godot.Collections.Array<ShipModule>();
	
	private static Godot.Collections.Dictionary<String, ShipModule> moduleDatabase;
	
	private void refreshDatabase()
	{
		if(Godot.DirAccess.Open(armoryDirectory) is DirAccess directory)
		{
			String[] filenames = directory.GetFiles();
			//GD.Print("Files found: " + filenames.Length.ToString() + "\n");
			moduleDatabase = new Godot.Collections.Dictionary<String, ShipModule>();
			foreach(String filename in filenames)
			{
				//GD.Print(filename);
				if(filename.EndsWith(".tres"))
				{
					ShipModule loadedModule =
						ResourceLoader.Load<ShipModule>
							(
								armoryDirectory + "/" + filename, "ShipModule"
							);
					String moduleName = filename.Split('.')[0];
					moduleDatabase.Add(moduleName, loadedModule);
				}
			}
		}
		else
		{
			GD.PrintErr("Directory not found!");

		}
	}

	// Called when the node enters the scene tree for the first time.
	public override void _Ready()
	{
		refreshDatabase();

		foreach(ShipModule m in moduleDatabase.Values)
		{
		}
	}
}
