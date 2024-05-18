#include "Game.as"

#define CLIENT_ONLY

const string CARD_SPRITE_SHEET = "uno.png";
const u8 CARD_SPRITE_SHEET_COLUMNS = 13;
const u8 CARD_SPRITE_SHEET_ROWS = 5;

void onInit(CRules@ this)
{
	Render::addScript(Render::layer_prehud, getCurrentScriptName(), "Render", 0);

    Vec2f offset = Vec2f(-2.5, -2.5) * cl_mouse_scale;
    getHUD().SetCursorOffset(offset);
}

void Render(int id)
{
	Render::SetAlphaBlend(true);
	Render::SetZBuffer(true, true);
	Render::SetBackfaceCull(true);
	Render::ClearZ();
	Render::SetTransformScreenspace();

	Vec2f position = Vec2f(200, 200);
	float rotation = 45.0f;
	float scale = getCardDimensions().y;

	u16 card = isMouseOverCard(position, rotation, scale)
		? Card::Color::Green | Card::Value::Draw2
		: Card::Color::Red | Card::Value::Draw2;
	DrawCard(card, position, rotation, scale);

	Game@ game = GameManager::get();
	if (game is null) return;

	// DrawPile(Vec2f(10, 10), game.getDrawPile());
	// DrawPile(game.getDiscardPile());

	// u16[] hand;
	// if (game.getHand(getLocalPlayer(), hand)
	// {
	// 	DrawHand(hand);
	// }
}

Vec2f getCardSpriteCoords(u16 card)
{
	// Default to back of card
	uint x = 0;
	uint y = 4;

	bool invalid = false;

	switch (card & Card::Mask::Color)
	{
		case Card::Color::Yellow:
			y = 0;
			break;
		case Card::Color::Red:
			y = 1;
			break;
		case Card::Color::Blue:
			y = 2;
			break;
		case Card::Color::Green:
			y = 3;
			break;
		case Card::Color::Wild:
			x = 1;
			y = 4;
			break;
		default:
			invalid = true;
			break;

	}

	switch (card & Card::Mask::Value)
	{
		case Card::Value::One:
			x = 0;
			break;
		case Card::Value::Two:
			x = 1;
			break;
		case Card::Value::Three:
			x = 2;
			break;
		case Card::Value::Four:
			x = 3;
			break;
		case Card::Value::Five:
			x = 4;
			break;
		case Card::Value::Six:
			x = 5;
			break;
		case Card::Value::Seven:
			x = 6;
			break;
		case Card::Value::Eight:
			x = 7;
			break;
		case Card::Value::Nine:
			x = 8;
			break;
		case Card::Value::Zero:
			x = 9;
			break;
		case Card::Value::Draw2:
			x = 10;
			break;
		case Card::Value::Skip:
			x = 11;
			break;
		case Card::Value::Reverse:
			x = 12;
			break;
		case Card::Value::Draw4:
			x = 2;
			y = 4;
			break;
		default:
			invalid = true;
			break;
	}

	if (invalid)
	{
		// Blank black card
		x = 3;
		y = 4;
	}

	return Vec2f(x, y);
}

Vec2f getCardDimensions()
{
	Vec2f imageDim;
	GUI::GetImageDimensions(CARD_SPRITE_SHEET, imageDim);

	return Vec2f(
		imageDim.x / CARD_SPRITE_SHEET_COLUMNS,
		imageDim.y / CARD_SPRITE_SHEET_ROWS
	);
}

Vec2f getNormalisedCardDimensions()
{
	Vec2f cardDim = getCardDimensions();
	return cardDim / Maths::Max(cardDim.x, cardDim.y) * 0.5f;
}

Vertex[] getVertices(u16 card)
{
	// XY coordinates
	Vec2f halfDim = getNormalisedCardDimensions() * 0.5f;

	// UV coordinates
	Vec2f cardCoords = getCardSpriteCoords(card);
	Vec2f spriteCoords = Vec2f(CARD_SPRITE_SHEET_COLUMNS, CARD_SPRITE_SHEET_ROWS);

	Vec2f u = Vec2f(cardCoords.x / spriteCoords.x, cardCoords.y / spriteCoords.y);
	Vec2f v = Vec2f((cardCoords.x + 1) / spriteCoords.x, (cardCoords.y + 1) / spriteCoords.y);

	// Vertices
	Vertex[] vertices = {
		Vertex( halfDim.x, -halfDim.y, 0, v.x, u.y, color_white),
		Vertex( halfDim.x,  halfDim.y, 0, v.x, v.y, color_white),
		Vertex(-halfDim.x,  halfDim.y, 0, u.x, v.y, color_white),
		Vertex(-halfDim.x, -halfDim.y, 0, u.x, u.y, color_white)
	};

	return vertices;
}

bool isMouseOverCard(Vec2f position, float rotation, float scale)
{
	float radians = toRadians(rotation);
	float sin = Maths::Sin(radians);
	float cos = Maths::Cos(radians);

	// Calculate the position of the mouse relative to the card's rotation
	// https://stackoverflow.com/a/7328496/10456572
	Vec2f deltaMousePos = getControls().getInterpMouseScreenPos() - position;
	Vec2f mousePos = Vec2f(
		position.x + sin * deltaMousePos.y + cos * deltaMousePos.x,
		position.y + sin * deltaMousePos.y - cos * deltaMousePos.x
	);

	Vec2f halfDim = getNormalisedCardDimensions() * scale * 0.5f;

	return (
		mousePos.y > position.y - halfDim.y &&
		mousePos.y < position.y + halfDim.y &&
		mousePos.x > position.x - halfDim.x &&
		mousePos.x < position.x + halfDim.x
	);
}

void DrawCard(u16 card, Vec2f position, float rotation, float scale)
{
	float[] translationMatrix;
	Matrix::MakeIdentity(translationMatrix);
	Matrix::SetTranslation(translationMatrix, position.x, position.y, 0);
	Matrix::SetScale(translationMatrix, scale, scale, 1);

	float[] rotationMatrix;
	Matrix::MakeIdentity(rotationMatrix);
	Matrix::SetRotationDegrees(rotationMatrix, 0, 0, rotation);

	float[] matrix;
	Matrix::Multiply(translationMatrix, rotationMatrix, matrix);

	Vertex[] vertices = getVertices(card);

	Render::SetModelTransform(matrix);
	Render::SetModelTransform(matrix);
	Render::RawQuads(CARD_SPRITE_SHEET, vertices);
}

void DrawPile(Vec2f position, u16[] cards)
{

}

void DrawHand(Vec2f position, u16[] cards)
{

}
