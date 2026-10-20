using UnityEngine;

/// Simula una boya: bobbing vertical + balanceo suave.
/// Versión corregida para funcionar como hijo de una plataforma móvil.
/// 
/// La clave es trabajar en espacio LOCAL, no en espacio GLOBAL.
/// Así el objeto mantiene su movimiento relativo al padre y hereda correctamente
/// el movimiento de la plataforma.
[DisallowMultipleComponent]
public class HoloMotion: MonoBehaviour
{
    [Header("Vertical (sube/baja)")]
    [Tooltip("Altura máxima del vaivén vertical en metros.")]
    public float verticalAmplitude = 0.35f;

    [Tooltip("Ciclos por segundo del movimiento vertical.")]
    public float verticalFrequency = 0.25f;

    [Tooltip("Cantidad extra de variación basada en ruido Perlin.")]
    [Range(0f, 1f)]
    public float verticalNoise = 0.25f;

    [Header("Rotación (penduleo)")]
    [Tooltip("Grados máximos de pitch X y roll Z.")]
    public Vector2 tiltAmplitudeDegrees = new Vector2(6f, 10f);

    [Tooltip("Ciclos por segundo del balanceo.")]
    public float tiltFrequency = 0.18f;

    [Tooltip("Suavizado de la rotación. Más alto = responde más rápido.")]
    public float tiltSmoothing = 6f;

    [Tooltip("Variación extra basada en ruido Perlin.")]
    [Range(0f, 1f)]
    public float tiltNoise = 0.35f;

    [Header("Fase / aleatoriedad")]
    [Tooltip("Semilla para desincronizar múltiples boyas.")]
    public int seed = 12345;

    [Tooltip("Offset de fase en segundos. Si se deja en 0, se deriva de la semilla.")]
    public float phaseOffsetSeconds = 0f;

    private Vector3 _baseLocalPos;
    private Quaternion _baseLocalRot;

    private float _phaseA;
    private float _phaseB;
    private float _perlinOffsetA;
    private float _perlinOffsetB;

    private void Awake()
    {
        CacheLocalBaseTransform();
        InitRandomValues();
    }

    private void OnEnable()
    {
        // Recaptura la posición local base al activar el objeto.
        // Importante: se guarda la posición relativa al padre, no la global.
        CacheLocalBaseTransform();
    }

    private void CacheLocalBaseTransform()
    {
        _baseLocalPos = transform.localPosition;
        _baseLocalRot = transform.localRotation;
    }

    private void InitRandomValues()
    {
        var rng = new System.Random(seed);

        _phaseA = (float)rng.NextDouble() * 1000f;
        _phaseB = (float)rng.NextDouble() * 1000f;

        _perlinOffsetA = (float)rng.NextDouble() * 1000f;
        _perlinOffsetB = (float)rng.NextDouble() * 1000f;

        if (phaseOffsetSeconds == 0f)
            phaseOffsetSeconds = (float)rng.NextDouble() * 10f;
    }

    private void LateUpdate()
    {
        float t = Time.time + phaseOffsetSeconds;

        // -------------------------
        // Movimiento vertical local
        // -------------------------

        float verticalAngularSpeed = Mathf.PI * 2f * verticalFrequency;
        float verticalSin = Mathf.Sin(verticalAngularSpeed * t + _phaseA);

        // Perlin convertido de [0,1] a [-1,1]
        float verticalPerlin =
            Mathf.PerlinNoise(_perlinOffsetA, t * verticalFrequency * 0.7f) * 2f - 1f;

        float yOffset = verticalAmplitude * (verticalSin + verticalPerlin * verticalNoise);

        Vector3 localPos = _baseLocalPos;
        localPos.y += yOffset;

        transform.localPosition = localPos;

        // -------------------------
        // Rotación local
        // -------------------------

        float tiltAngularSpeed = Mathf.PI * 2f * tiltFrequency;

        float sinPitch = Mathf.Sin(tiltAngularSpeed * t + _phaseB);
        float sinRoll = Mathf.Sin(tiltAngularSpeed * t * 0.93f + _phaseB + 1.7f);

        float perlinPitch =
            Mathf.PerlinNoise(_perlinOffsetB, t * tiltFrequency * 0.8f) * 2f - 1f;

        float perlinRoll =
            Mathf.PerlinNoise(_perlinOffsetB + 10.1f, t * tiltFrequency * 0.8f) * 2f - 1f;

        float pitch = tiltAmplitudeDegrees.x * (sinPitch + perlinPitch * tiltNoise);
        float roll = tiltAmplitudeDegrees.y * (sinRoll + perlinRoll * tiltNoise);

        Quaternion targetLocalRot = _baseLocalRot * Quaternion.Euler(pitch, 0f, roll);

        transform.localRotation = Quaternion.Slerp(
            transform.localRotation,
            targetLocalRot,
            1f - Mathf.Exp(-tiltSmoothing * Time.deltaTime)
        );
    }
}