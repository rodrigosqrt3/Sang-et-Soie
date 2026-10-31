extends CanvasLayer
class_name ScreenGrade

# The final look of every frame: a soft vignette and a fixed paper grain, and
# when Le Regard is raised, the world drains to a cold monocle tint.

const SHADER_CODE: String = """
shader_type canvas_item;
uniform sampler2D screen_texture : hint_screen_texture, filter_linear_mipmap;
uniform float regard = 0.0;
uniform float vignette = 0.5;
uniform float grain = 0.035;
uniform vec4 regard_tint : source_color = vec4(0.62, 0.9, 0.82, 1.0);

float hash(vec2 p) {
	return fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453);
}

void fragment() {
	vec4 c = texture(screen_texture, SCREEN_UV);
	float lum = dot(c.rgb, vec3(0.299, 0.587, 0.114));
	vec3 graded = mix(c.rgb, vec3(lum) * regard_tint.rgb * 1.2, regard * 0.72);
	vec2 d = UV - vec2(0.5);
	float v = smoothstep(0.82, 0.22, length(d) * (1.0 + regard * 0.7));
	graded *= mix(1.0 - vignette, 1.0, v);
	// Paper grain is fixed in place, like the fibres of a sheet.
	float n = hash(floor(FRAGCOORD.xy * 0.5)) - 0.5;
	graded += n * grain;
	COLOR = vec4(graded, 1.0);
}
"""

static var _shader: Shader

var material: ShaderMaterial
var regard_amount: float = 0.0

func _ready() -> void:
	layer = 5
	process_mode = Node.PROCESS_MODE_ALWAYS
	if _shader == null:
		_shader = Shader.new()
		_shader.code = SHADER_CODE
	material = ShaderMaterial.new()
	material.shader = _shader
	var rect: ColorRect = ColorRect.new()
	rect.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	rect.material = material
	add_child(rect)

func _process(delta: float) -> void:
	var target: float = 0.0
	for player in get_tree().get_nodes_in_group("player"):
		if bool(player.get("is_using_monocle")):
			target = 1.0
	regard_amount = move_toward(regard_amount, target, delta * 4.0 / maxf(0.2, Engine.time_scale))
	material.set_shader_parameter("regard", regard_amount)
