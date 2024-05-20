#include "Game.as"
#include "RenderCard.as"
#include "RenderManager.as"
#include "GameStart.as"
#include "CardDraw.as"
#include "CardPlay.as"
#include "TurnNext.as"
#include "TurnSkip.as"

#define CLIENT_ONLY

const string CARD_SPRITE_SHEET = "uno.png";
const u8 CARD_SPRITE_SHEET_COLUMNS = 13;
const u8 CARD_SPRITE_SHEET_ROWS = 5;
const float CARD_SCALE = 256.0f;

RenderManager renderManager;
dictionary renderCards;

void onInit(CRules@ this)
{
	Render::addScript(Render::layer_prehud, getCurrentScriptName(), "Render", 0);

    Vec2f offset = Vec2f(-2.5, -2.5) * cl_mouse_scale;
    getHUD().SetCursorOffset(offset);
}

void onCommand(CRules@ this, u8 cmd, CBitStream@ params)
{
	if (!isServer() && cmd == this.getCommandID("init game"))
	{
		u32 seed;
		if (!params.saferead_u32(seed)) return;

		u16 playerCount;
		if (!params.saferead_u16(playerCount)) return;

		string[] players;

		for (uint i = 0; i < playerCount; i++)
		{
			string player;
			if (!params.saferead_string(player)) return;

			players.push_back(player);
		}

		Game@ game = Game(players, OfficialRuleset(), seed);

		u16[] deck = game.getDeck();
		for (uint i = 0; i < deck.size(); i++)
		{
			u16 card = deck[i];
			renderCards.set("" + card, RenderCard(card));

		}

		RenderState@ state = GameStart(game);
		renderManager.Add(state);
	}
	else if (!isServer() && cmd == this.getCommandID("sync game"))
	{
		Game@ game = Game(params);

		u16[] deck = game.getDeck();
		for (uint i = 0; i < deck.size(); i++)
		{
			u16 card = deck[i];
			renderCards.set("" + card, RenderCard(card));
		}

		GameManager::Set(game);
	}
	else if (!isServer() && cmd == this.getCommandID("end game"))
	{
		Game@ game = GameManager::get();
		if (game is null) return;

		game.End();
	}
	else if (!isServer() && cmd == this.getCommandID("remove player"))
	{
		Game@ game = GameManager::get();
		if (game is null) return;

		string player;
		if (!params.saferead_string(player)) return;

		game.RemovePlayer(player);
	}
	else if (!isServer() && cmd == this.getCommandID("next turn"))
	{
		Game@ game = GameManager::get();
		if (game is null) return;

		RenderState@ state = TurnNext(game);
		renderManager.Add(state);
	}
	else if (!isServer() && cmd == this.getCommandID("skip turn"))
	{
		Game@ game = GameManager::get();
		if (game is null) return;

		RenderState@ state = TurnSkip(game);
		renderManager.Add(state);
	}
	else if (!isServer() && cmd == this.getCommandID("reverse direction"))
	{
		Game@ game = GameManager::get();
		if (game is null) return;

		game.ReverseDirection();
	}
	else if (!isServer() && cmd == this.getCommandID("draw card"))
	{
		Game@ game = GameManager::get();
		if (game is null) return;

		RenderState@ state = CardDraw(game, renderCards);
		renderManager.Add(state);
	}
	else if (!isServer() && cmd == this.getCommandID("play card"))
	{
		Game@ game = GameManager::get();
		if (game is null) return;

		string player;
		if (!params.saferead_string(player)) return;

		u16 card;
		if (!params.saferead_u16(card)) return;

		RenderState@ state = CardPlay(game, renderCards, player, card);
		renderManager.Add(state);
	}
	else if (!isServer() && cmd == this.getCommandID("swap hands"))
	{
		Game@ game = GameManager::get();
		if (game is null) return;

		string player1;
		if (!params.saferead_string(player1)) return;

		string player2;
		if (!params.saferead_string(player2)) return;

		game.SwapHands(player1, player2);
	}
	else if (!isServer() && cmd == this.getCommandID("replenish draw pile"))
	{
		Game@ game = GameManager::get();
		if (game is null) return;

		game.ReplenishDrawPile();
	}
}

void onRender(CRules@ this)
{
	Game@ game = GameManager::get();
	if (game is null) return;

	GUI::SetFont("menu");

	uint yIndex = 0;

	GUI::DrawText("Turn: " + game.getTurnPlayer(), Vec2f(10, 10 + 15 * yIndex++), color_white);

	yIndex++;

	GUI::DrawText("Draw pile: " + stringifyCards(game.getDrawPile()), Vec2f(10, 10 + 15 * yIndex++), color_white);
	GUI::DrawText("Discard pile: " + stringifyCards(game.getDiscardPile()), Vec2f(10, 10 + 15 * yIndex++), color_white);

	yIndex++;

	string[] players = game.getPlayers();
	for (uint i = 0; i < players.size(); i++)
	{
		string player = players[i];

		u16[] hand;
		game.getHand(player, hand);

		GUI::DrawText(player + ": " + stringifyCards(hand), Vec2f(10, 10 + 15 * yIndex++), color_white);
	}
}

void Render(int id)
{
	Render::SetAlphaBlend(true);
	Render::SetZBuffer(true, true);
	Render::SetBackfaceCull(true);
	Render::ClearZ();
	Render::SetTransformScreenspace();

	renderManager.Render();

	// Vec2f position = Vec2f(CARD_SCALE, CARD_SCALE);
	// float angle = 45.0f;
	// float scale = getCardDimensions().y;

	// u16 card = isMouseOverCard(position, angle, scale)
	// 	? Card::Color::Green | Card::Value::Draw2
	// 	: Card::Color::Red | Card::Value::Draw2;
	// DrawCard(card, position, angle, scale);

	Game@ game = GameManager::get();
	if (game is null) return;

	Vec2f screenCenter = getDriver().getScreenCenterPos();

	DrawPile(game.getDrawPile(), screenCenter + Vec2f(-60, -100));
	DrawPile(game.getDiscardPile(), screenCenter + Vec2f(60, -100));

	u16[] hand;
	if (game.getHand(getLocalPlayer().getUsername(), hand))
	{
		DrawHand(hand, screenCenter + Vec2f(0, 100));
	}
}

string stringifyCards(u16[] cards)
{
	string[] cardNames;

	for (uint i = 0; i < cards.size(); i++)
	{
		u16 card = cards[i];
		cardNames.push_back(Card::getName(card) + " (" + card + ")");
	}

	if (cardNames.empty())
	{
		return "{}";
	}

	return "{ " + join(cardNames, ", ") + " }";
}

Vec2f getCardSpriteCoords(u16 card)
{
	// Default to back of card
	uint x = 0;
	uint y = 4;

	bool invalid = false;

	if (Card::hasFlags(card, Card::Flag::Wild))
	{
		x = 1;
		y = 4;
	}
	else
	{
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
			default:
				invalid = true;
				break;
		}
	}

	switch (card & Card::Mask::Value)
	{
		case Card::Value::None:
			break;
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

// Thanks ChatGPT!
bool isMouseOverCard(Vec2f position, float angle, float scale)
{
	Vec2f cardSize = getNormalisedCardDimensions() * scale;

	// Translate the point into the local coordinate system of the OBB
	Vec2f mousePos = getControls().getInterpMouseScreenPos() - position;

    // Rotate the translated point by the negative angle of rotation of the OBB
	float radians = toRadians(-angle);
	float sin = Maths::Sin(radians);
	float cos = Maths::Cos(radians);
    float rotatedX = mousePos.x * cos - mousePos.y * sin;
    float rotatedY = mousePos.x * sin + mousePos.y * cos;

    // Check if the rotated point lies within the bounds of the OBB
	return (
		Maths::Abs(rotatedX) <= cardSize.x * 0.5f &&
		Maths::Abs(rotatedY) <= cardSize.y * 0.5f
	);
}

void DrawCard(u16 card, Vec2f position, float angle, float scale)
{
	float[] translationMatrix;
	Matrix::MakeIdentity(translationMatrix);
	Matrix::SetTranslation(translationMatrix, position.x, position.y, 0);
	Matrix::SetScale(translationMatrix, scale, scale, 1);

	float[] rotationMatrix;
	Matrix::MakeIdentity(rotationMatrix);
	Matrix::SetRotationDegrees(rotationMatrix, 0, 0, angle);

	float[] matrix;
	Matrix::Multiply(translationMatrix, rotationMatrix, matrix);

	Vertex[] vertices = getVertices(card);

	Render::SetModelTransform(matrix);
	Render::SetModelTransform(matrix);
	Render::RawQuads(CARD_SPRITE_SHEET, vertices);
}

void DrawPile(u16[] cards, Vec2f position)
{
	u16 count = cards.size();

	for (uint i = 0; i < count; i++)
	{
		u16 card = Card::clean(cards[i]);

		Vec2f cardPosition = position - Vec2f(0.0f, 0.5f * i);
		float cardAngle = 0.0f;
		float cardScale = CARD_SCALE;

		RenderCard@ renderCard;
		renderCards.get("" + card, @renderCard);

		renderCard.SetPosition(cardPosition);
		renderCard.SetAngle(cardAngle);
		renderCard.SetScale(cardScale);

		renderCard.Render();
	}
}

void DrawHand(u16[] cards, Vec2f position)
{
	u16 count = cards.size();

	for (uint i = 0; i < count; i++)
	{
		u16 card = Card::clean(cards[i]);

		float index = i - count * 0.5f + 0.5f;
		Vec2f cardPosition = position + Vec2f(index * 30, Maths::Pow(1.2f, Maths::Abs(index)) * 10);
		float cardAngle = index * 4.0f;
		float cardScale = CARD_SCALE;

		if (isMouseOverCard(cardPosition, cardAngle, cardScale))
		{
			cardPosition.y -= 40;
		}

		RenderCard@ renderCard;
		renderCards.get("" + card, @renderCard);

		renderCard.SetPosition(cardPosition);
		renderCard.SetAngle(cardAngle);
		renderCard.SetScale(cardScale);

		renderCard.Render();
	}
}
