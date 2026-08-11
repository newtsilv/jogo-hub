class_name QuestionBox
extends Control

signal question_answered(
	was_correct: bool,
	selected_index: int
)


enum QuestionTheme {
	INCODE,
	HUB
}


# =========================================================
# TEMA INCODE
# =========================================================

@export_category("Tema Incode")

# Imagem de fundo da caixa de pergunta
@export var incodebox: Texture2D

# Imagem normal das opções
@export var botaoincode: Texture2D

# Imagem verde da opção correta
@export var botaoincode_correto: Texture2D

# Imagem vermelha da opção errada
@export var botaoincode_errado: Texture2D


# =========================================================
# TEMA HUB
# =========================================================

@export_category("Tema Hub")

# Imagem de fundo da caixa de pergunta
@export var hubbox: Texture2D

# Imagem normal das opções
@export var botao: Texture2D

# Imagem verde da opção correta
@export var botao_correto: Texture2D

# Imagem vermelha da opção errada
@export var botao_errado: Texture2D


# =========================================================
# ANIMAÇÕES
# =========================================================

@export_category("Animação")

@export var opening_duration: float = 0.25
@export var closing_duration: float = 0.15
@export var entrance_offset: float = 80.0

# Quantas vezes o botão pisca
@export var flash_count: int = 3

# Tempo de cada estado do piscar
@export var flash_duration: float = 0.12


@export_category("Texto das respostas")
@export var answer_label_margin: float = 28.0
@export var answer_label_font_size: int = 25


# =========================================================
# REFERÊNCIAS DOS NÓS
# =========================================================

@onready var background: TextureRect = $Background

@onready var question_text_label: RichTextLabel = (
	$QuestionText
)


# Os botões não devem usar @export.
# Eles são encontrados automaticamente pela árvore da cena.
@onready var answer_buttons: Array[TextureButton] = [
	$Answer1,
	$Answer2,
	$Answer3
]


@onready var answer_labels: Array[Label] = [
	$Answer1/AnswerLabel,
	$Answer2/AnswerLabel,
	$Answer3/AnswerLabel
]


# =========================================================
# ESTADO
# =========================================================

var correct_answer_index: int = 0

var question_is_open: bool = false
var accepting_answer: bool = false

var original_position: Vector2
var current_tween: Tween


# Texturas do tema atualmente selecionado
var current_normal_button_texture: Texture2D = null
var current_correct_button_texture: Texture2D = null
var current_wrong_button_texture: Texture2D = null


# =========================================================
# INICIALIZAÇÃO
# =========================================================

func _ready() -> void:
	original_position = position

	for index: int in range(answer_buttons.size()):
		var button: TextureButton = answer_buttons[index]
		var answer_label: Label = answer_labels[index]

		configure_answer_label(answer_label)

		if button == null:
			push_error(
				"Answer%s não foi encontrado."
				% (index + 1)
			)
			continue

		button.pressed.connect(
			_on_answer_pressed.bind(index)
		)

	hide()


func configure_answer_label(answer_label: Label) -> void:
	if answer_label == null:
		return

	answer_label.anchor_left = 0.0
	answer_label.anchor_top = 0.0
	answer_label.anchor_right = 1.0
	answer_label.anchor_bottom = 1.0

	answer_label.offset_left = answer_label_margin
	answer_label.offset_top = 8.0
	answer_label.offset_right = -answer_label_margin
	answer_label.offset_bottom = -8.0

	answer_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	answer_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	answer_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	answer_label.clip_text = true
	answer_label.add_theme_font_size_override(
		"font_size",
		answer_label_font_size
	)


# =========================================================
# ABRIR UMA PERGUNTA
# =========================================================

func start_question(question: Dictionary) -> void:
	if question.is_empty():
		push_warning("A pergunta recebida está vazia.")
		return

	var answers_value: Variant = question.get(
		"answers",
		[]
	)

	var answers: Array = answers_value as Array

	if answers.size() != 3:
		push_error(
			"A pergunta precisa ter exatamente 3 respostas."
		)
		return

	question_is_open = true
	accepting_answer = true

	correct_answer_index = int(
		question.get(
			"correct_answer",
			0
		)
	)

	# Proteção para não receber índice inválido.
	correct_answer_index = clampi(
		correct_answer_index,
		0,
		2
	)

	var theme_id: int = int(
		question.get(
			"theme",
			QuestionTheme.INCODE
		)
	)

	apply_theme(theme_id)

	question_text_label.text = str(
		question.get(
			"question",
			""
		)
	)
	question_text_label.scroll_active = false

	for index: int in range(answer_buttons.size()):
		var button: TextureButton = answer_buttons[index]
		var answer_label: Label = answer_labels[index]

		answer_label.text = str(answers[index])

		button.modulate = Color.WHITE
		button.disabled = false
		button.show()

		set_button_texture(
			button,
			current_normal_button_texture
		)

	show()
	animate_opening()


# =========================================================
# TEMAS
# =========================================================

func apply_theme(theme_id: int) -> void:
	match theme_id:
		QuestionTheme.INCODE:
			background.texture = incodebox

			current_normal_button_texture = (
				botaoincode
			)

			current_correct_button_texture = (
				botaoincode_correto
			)

			current_wrong_button_texture = (
				botaoincode_errado
			)

		QuestionTheme.HUB:
			background.texture = hubbox

			current_normal_button_texture = botao
			current_correct_button_texture = botao_correto
			current_wrong_button_texture = botao_errado

		_:
			background.texture = incodebox

			current_normal_button_texture = (
				botaoincode
			)

			current_correct_button_texture = (
				botaoincode_correto
			)

			current_wrong_button_texture = (
				botaoincode_errado
			)

	for button: TextureButton in answer_buttons:
		if button == null:
			continue

		set_button_texture(
			button,
			current_normal_button_texture
		)


func set_button_texture(
	button: TextureButton,
	texture: Texture2D
) -> void:
	if button == null:
		return

	if texture == null:
		return

	button.texture_normal = texture
	button.texture_pressed = texture
	button.texture_hover = texture
	button.texture_focused = texture
	button.texture_disabled = texture


# =========================================================
# RESPOSTA SELECIONADA
# =========================================================

func _on_answer_pressed(
	answer_index: int
) -> void:
	if not question_is_open:
		return

	if not accepting_answer:
		return

	if answer_index < 0:
		return

	if answer_index >= answer_buttons.size():
		return

	accepting_answer = false
	disable_answer_buttons()

	var was_correct: bool = (
		answer_index == correct_answer_index
	)

	var selected_button: TextureButton = (
		answer_buttons[answer_index]
	)

	await flash_answer_button(
		selected_button,
		was_correct
	)

	question_answered.emit(
		was_correct,
		answer_index
	)


# =========================================================
# PISCAR BOTÃO
# =========================================================

func flash_answer_button(
	button: TextureButton,
	was_correct: bool
) -> void:
	var feedback_texture: Texture2D = null

	if was_correct:
		feedback_texture = (
			current_correct_button_texture
		)
	else:
		feedback_texture = (
			current_wrong_button_texture
		)

	# Caso a textura verde/vermelha não tenha sido
	# configurada, mantém a imagem normal.
	if feedback_texture == null:
		feedback_texture = (
			current_normal_button_texture
		)

	for _index: int in range(flash_count):
		set_button_texture(
			button,
			feedback_texture
		)

		await get_tree().create_timer(
			flash_duration
		).timeout

		set_button_texture(
			button,
			current_normal_button_texture
		)

		await get_tree().create_timer(
			flash_duration
		).timeout

	# Termina mostrando o resultado escolhido.
	set_button_texture(
		button,
		feedback_texture
	)


func disable_answer_buttons() -> void:
	for button: TextureButton in answer_buttons:
		if button != null:
			button.disabled = true


# =========================================================
# ANIMAÇÃO DE ABERTURA
# =========================================================

func animate_opening() -> void:
	if current_tween != null:
		current_tween.kill()

	modulate.a = 0.0

	position = original_position + Vector2(
		0.0,
		entrance_offset
	)

	current_tween = create_tween()
	current_tween.set_parallel(true)

	current_tween.tween_property(
		self,
		"modulate:a",
		1.0,
		opening_duration
	)

	current_tween.tween_property(
		self,
		"position",
		original_position,
		opening_duration
	).set_trans(
		Tween.TRANS_BACK
	).set_ease(
		Tween.EASE_OUT
	)


# =========================================================
# FECHAR A CAIXA
# =========================================================

func close_question_box() -> void:
	if not question_is_open:
		return

	question_is_open = false
	accepting_answer = false

	disable_answer_buttons()

	if current_tween != null:
		current_tween.kill()

	current_tween = create_tween()
	current_tween.set_parallel(true)

	current_tween.tween_property(
		self,
		"modulate:a",
		0.0,
		closing_duration
	)

	current_tween.tween_property(
		self,
		"position",
		original_position + Vector2(
			0.0,
			entrance_offset
		),
		closing_duration
	)

	await current_tween.finished

	hide()

	position = original_position
	modulate.a = 1.0

	reset_buttons()


func reset_buttons() -> void:
	for button: TextureButton in answer_buttons:
		if button == null:
			continue

		button.disabled = false
		button.modulate = Color.WHITE

		set_button_texture(
			button,
			current_normal_button_texture
		)
