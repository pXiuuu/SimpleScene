// Copyright(C) David W. Jeske, 2014, All Rights Reserved.
#version 120

uniform vec3 viewRay;
#ifdef INSTANCE_DRAW
attribute vec3 cylinderCenter;
attribute vec3 cylinderAxis; // must be normalized
attribute float cylinderWidth;
attribute float cylinderLength;
attribute vec4 cylinderColor;
#else
uniform vec3 cylinderCenter;
uniform vec3 cylinderAxis; // must be normalized
uniform float cylinderWidth;
uniform float cylinderLength;
#endif
varying vec3 varCylinderCenter;
varying vec3 varCylinderAxis;
varying float varCylinderLength;
varying float varCylinderWidth;
#ifdef INSTANCE_DRAW
varying vec4 varCylinderColor;
#endif

// http://www.opengl.org/discussion_boards/showthread.php/160134-Quaternion-functions-for-GLSL
//vec3 quatTransform(vec4 q, vec3 v)
//{
//    return v + 2.0*cross(cross(v, q.xyz ) + q.w*v, q.xyz);
//}

void main()
{
    vec4 color = cylinderColor;
    
    #if 1
    //vec3 viewRay = normalize(gl_ModelViewMatrixInverse * vec4(0, 0, -1, 1)).xyz;
    //vec3 viewRayX = normalize(gl_ModelViewMatrixInverse * vec4(1, 0, 0, 1)).xyz;
    //viewRay = normalize(quatTransform(rotationQuat, vec3(0, 0, -1)).xyz);
   
    vec3 centerInView = (gl_ModelViewMatrix * vec4(cylinderCenter, 1)).xyz;
    vec3 scaledAxis = (cylinderLength/2 + cylinderWidth) * cylinderAxis;
    
    vec3 endInView = (gl_ModelViewMatrix * vec4(cylinderCenter + scaledAxis, 1)).xyz;
    vec3 scaledAxisInView = endInView - centerInView;
    vec3 startInView = centerInView - scaledAxisInView;

    #if 0
    float expand = (gl_ModelViewMatrix * vec4(cylinderCenter + viewRayX * cylinderWidth, 1.0)).x - centerInView.x;
    if (length(scaledAxisInView) < cylinderWidth) {
        scaledAxisInView = vec3(expand, expand, 0);
        color = vec4(0, 0, 0.5, 1);
    }
    #endif


    if (length(scaledAxisInView.xy) < 2*cylinderWidth) {
        scaledAxisInView.xy = normalize(scaledAxisInView.xy) * 2*cylinderWidth;
    }
    
    vec2 axisInViewPerp = normalize(vec2(-scaledAxisInView.y, scaledAxisInView.x)) * 2 * cylinderWidth;
    #endif
 
   
    vec3 viewPos = centerInView 
        + gl_Vertex.x * vec3(scaledAxisInView.xy, 0)
        + gl_Vertex.y * vec3(axisInViewPerp, 0) * 4;
    gl_Position = gl_ProjectionMatrix * vec4(viewPos, 1);

    
    varCylinderCenter = cylinderCenter;
    varCylinderAxis = cylinderAxis;
    varCylinderWidth = cylinderWidth;
    varCylinderLength = cylinderLength;

    #ifdef INSTANCE_DRAW
    //varCylinderColor = vec4(0, 0, 0, 1);
    //varCylinderColor.x = length(viewPos - startInView)/cylinderLength;
    //varCylinderColor.y = length(viewPos - endInView)/cylinderLength;
    varCylinderColor = color;
    #endif
    
}

    #if 0
    vec3 rotatedScaledAxis = quatTransform(rotationQuat, scaledAxis);
    
    float theta = -atan(rotatedScaledAxis.y/rotatedScaledAxis.x);
    //float theta = 3.1415 / 4;
    //float theta = atan(cylinderAxis.y / cylinderAxis.x);
    float cosine = cos(theta);
    float sine = sin(theta);
    mat3 oriZ = mat3(cosine, sine, 0, 
                     -sine, cosine, 0, 
                     0, 0, 1);
    #endif


    #if 0
    vec3 viewPos = centerInView
        + oriZ * vec3(gl_Vertex.x * length(scaledAxisInView),
               gl_Vertex.y * cylinderWidth,
               0);
    gl_Position = gl_ProjectionMatrix * vec4(viewPos, 1);
    #endif


#if 0
    vec3 combinedPos = gl_Vertex.xyz;    
    combinedPos.x *= max(length(scaledAxisInView.xy*2), cylinderWidth*2);
    combinedPos.y *= cylinderWidth;
    combinedPos = oriZ * combinedPos;
    combinedPos = quatTransform(rotationQuat, combinedPos);
    combinedPos += cylinderCenter;
    combinedPos = (gl_ModelViewMatrix * vec4(combinedPos, 1)).xyz;
    gl_Position = gl_ProjectionMatrix * vec4(combinedPos, 1);
    #endif


    #if 0
    gl_Position = gl_ProjectionMatrix * vec4(centerInView + gl_Vertex.xyz,
                                            1);

    #endif
    
    #if 0
    vec3 pos = gl_Vertex.xyz;
    pos.x *= cylinderLength / 2;
    pos.y *= cylinderWidth;
    gl_Position = gl_ModelViewProjectionMatrix * vec4(pos + cylinderCenter, 1) ;
    #endif
 