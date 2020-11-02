using UnityEngine;

public class Tetrahedron : MonoBehaviour
{
    private void OnDrawGizmos()
    {
        Vector3 p1 = new Vector3( 1,  1,  0);
        Vector3 p2 = new Vector3(-1,  1,  0);
        Vector3 p3 = new Vector3( 0, -1,  1);
        Vector3 p4 = new Vector3( 0, -1, -1);

        Gizmos.DrawLine(p1, p2);
        Gizmos.DrawLine(p1, p3);
        Gizmos.DrawLine(p1, p4);

        Gizmos.DrawLine(p2, p3);
        Gizmos.DrawLine(p2, p4);

        Gizmos.DrawLine(p3, p4);
    }
}