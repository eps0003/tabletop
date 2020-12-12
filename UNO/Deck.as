#include "Card.as"

class Deck
{
	string name;
	string sprite;
	Vec2f cardDim;
	u16 backIndex;
	float scale;

	Deck(string name, string sprite, Vec2f cardDim, u16 backIndex, float scale = 1.0f)
	{
		this.name = name;
		this.sprite = sprite;
		this.cardDim = cardDim;
		this.backIndex = backIndex;
		this.scale = scale;
	}

	Vertex[] getVertices(Card@ card)
	{
		Vec2f imageDim;
		GUI::GetImageDimensions(sprite, imageDim);

		Vec2f halfDim = cardDim / 2.0f * scale;
		halfDim.x *= Maths::Abs(card.flip - 0.5f) * 2;

		u16 i = (card.flip > 0.5f && !card.hidden) ? card.index : backIndex;
		float x = imageDim.x / cardDim.x;
		float y = imageDim.y / cardDim.y;

		Vec2f u(i % int(x) / x, i / int(x) / y);
		Vec2f v = u + Vec2f(1.0f / x, 1.0f / y);

		Vertex[] vertices = {
			Vertex( halfDim.x, -halfDim.y, 0, v.x, u.y, color_white),
			Vertex( halfDim.x,  halfDim.y, 0, v.x, v.y, color_white),
			Vertex(-halfDim.x,  halfDim.y, 0, u.x, v.y, color_white),
			Vertex(-halfDim.x, -halfDim.y, 0, u.x, u.y, color_white)
		};

		return vertices;
	}

	void Serialize(CBitStream@ bs)
	{
		bs.write_string(name);
	}
}
