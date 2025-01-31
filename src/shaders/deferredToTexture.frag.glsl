#version 100
#extension GL_EXT_draw_buffers: enable
precision highp float;

uniform sampler2D u_colmap;
uniform sampler2D u_normap;

varying vec3 v_position;
varying vec3 v_normal;
varying vec2 v_uv;

vec3 applyNormalMap(vec3 geomnor, vec3 normap) {
    normap = normap * 2.0 - 1.0;
    vec3 up = normalize(vec3(0.001, 1, 0.001));
    vec3 surftan = normalize(cross(geomnor, up));
    vec3 surfbinor = cross(geomnor, surftan);
    return normap.y * surftan + normap.x * surfbinor + normap.z * geomnor;
}

// Code from https://jcgt.org/published/0003/02/01/paper.pdf
// Returns ±1
vec2 sign_not_zero(vec2 v) {
    return vec2((v.x >= 0.0) ? +1.0 : -1.0, (v.y >= 0.0) ? +1.0 : -1.0);
}
// Assume normalized input. Output is on [-1, 1] for each component.
vec2 encode_normal(vec3 v) {
    // Project the sphere onto the octahedron, and then onto the xy plane
    vec2 p = v.xy * (1.0 / (abs(v.x) + abs(v.y) + abs(v.z)));
    
    // Reflect the folds of the lower hemisphere over the diagonals
    return (v.z <= 0.0) ? ((1.0 - abs(p.yx)) * sign_not_zero(p)) : p;
}

void main() {
    vec3 norm = applyNormalMap(v_normal, vec3(texture2D(u_normap, v_uv)));
    vec3 col = vec3(texture2D(u_colmap, v_uv));

    // TODO: populate your g buffer
    // gl_FragData[0] = vec4(v_position, 1);
    // gl_FragData[1] = vec4(norm, 0);
    // gl_FragData[2] = vec4(col, 1);

    // Use compact g-buffers
    vec2 encoded_norm = encode_normal(norm);
    gl_FragData[0] = vec4(v_position, encoded_norm.x);
    gl_FragData[1] = vec4(encoded_norm.y, col);
    //
}