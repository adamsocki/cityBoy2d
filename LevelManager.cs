using Godot;

public partial class LevelManager : Node
{
	[Export]
	public Node2D SceneOne { get; set; }
	
	[Export]
	public Node2D SceneTwo { get; set; } // Corrected and using a property for best practice
	
	// private Node2D _sceneOneNode;

	public override void _Ready()
	{
		InitLevelManager();
	}

	public void InitLevelManager()
	{
		//GD.Print("InitLevelManager.");
		
		// Use the exported NodePath to get a reference to the node.
		// _sceneOneNode = GetNode<Node2D>(SceneOnePath);
		
		if (SceneOne != null)
		{
			// You can now safely use the _sceneOneNode variable.
			SceneOne.Visible = false;
			GD.Print("Scene one found and set to invisible.");
		}
		
		if (SceneTwo != null)
		{
			// The SceneTwo node was directly assigned in the editor.
			SceneTwo.Visible = true;
			GD.Print("Scene two found and set to invisible.");
		}
	}
}
