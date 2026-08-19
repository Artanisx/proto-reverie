shader_type spatial;

// The code in this shader only knows about one single vertex; nothing about the neighbors

// Export variable (uniform in shading language) that can be changed in the editor as a Shader Parameter
// Adding a hint_range provides a slider in the editor between the two ranges
// This is the wave frequency
uniform float wave_frequency : hint_range(0.05, 2.0) = 0.15;

// This is the wave speed
uniform float wave_speed : hint_range(0.1, 5.0) = 1.0;

// This is the wave amplitude
uniform float wave_amplitude : hint_range(0.01, 1.0) = 0.2;

// The property for the texture, that should have the nearest filter for pixel art and tilable so repeat_enable
uniform sampler2D liquid_texture : filter_nearest, repeat_enable;

// This is the speed of texture scrolling in X and Y
uniform vec2 texture_scroll_speed = vec2(0.05, 0.03);

// Transparency of the liquid
uniform float liquid_tarnsparency = 0.8;

// TIME is a property always available and starts at 0 when the game is launched
// Each frame will add to 0,016 (60fps, 16ms each)
// TIME 0, 0.016, 0.032,...

// Vertex Shader allows to change the POSITION
void vertex() 
{
	// MODEL_MATRIX is the global transform. multipling the vertex to the model_matrix you transform from local space to global space
	vec3 world_vertex = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz; // we need only xyz, but model_matris is vec4, so first we multiply making vertex a vec4 with a bonus 1.0 as w, then we only get the xyz of the result
	
	// Change the Y position of this vertex
	// sin goes between -1.0 and 1.0	
	float wave1 = sin(world_vertex.x * wave_frequency + TIME * wave_speed);
	
	// let's create another wave, this time with cos and z
	float wave2 = cos(world_vertex.z * wave_frequency * 0.8 + TIME * wave_speed * 1.2);
	
	// Apply the waves * amplitude to the y pos of the vertex
	VERTEX.y = (wave1 + wave2) * wave_amplitude;
}

// Fragment Shader allows to change the COLOR and other properties
void fragment()
{
	// returns the texture color of the vertex in r, g, b, alpha
	// passing a texture
	// and UV which returns the UV coordinate of this vertex
	// basically tex_color contains the precise pixel of texture UV wrapped in that vertex position
	// if we add TIME then we get some kind of scrolling because we're moving the UVs along the texture
	vec4 tex_color = texture(liquid_texture, UV + TIME * texture_scroll_speed);
	
	// Change the color of this vertex to the texture color uv wrapped
	// We don't need the alpha since ALBEDO only takes in a vec3, so we get the rgb from it
	ALBEDO = tex_color.rgb;
	
	// Change how the light effect this vertex
	METALLIC = 0.0;		// Not metallic
	ROUGHNESS = 1.0;	// Max Rough
	
	ALPHA = liquid_tarnsparency;
}
