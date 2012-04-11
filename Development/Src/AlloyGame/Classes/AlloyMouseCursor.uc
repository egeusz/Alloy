class AlloyMouseCursor extends Actor;

var() StaticMeshComponent Mesh;

DefaultProperties
{
        Begin Object Class=StaticMeshComponent Name=MarkerMesh
                BlockActors=false
                CollideActors=true
                BlockRigidBody=false
                StaticMesh=StaticMesh'CastleEffects.TouchToMoveArrow'
                //Materials[0]=MaterialInterface'EngineMaterials.ScreenMaterial'
                Scale3D=(X=2.0,Y=2.0,Z=2.0)
                Rotation=(Pitch=-16384, Yaw=0, Roll=0)
        End Object
        Mesh=MarkerMesh
        CollisionComponent=MarkerMesh
        Components.Add(MarkerMesh)
}