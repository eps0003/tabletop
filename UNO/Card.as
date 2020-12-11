#include "Grab.as"
#include "Deck.as"
#include "Utilities.as"

class Card
{
	private float easing = 0.07f;

	u16 index;

	Vec2f position;
	Vec2f targetPosition;

	float rotation;
	float targetRotation;

	float flip;
	bool flipped;
	bool hidden = false;

	Deck@ deck = Deck("playingCards.png", Vec2f(140, 190), 53);
	// Deck@ deck = Deck("uno.png", Vec2f(164, 256), 52);
	// Deck@ deck = Deck("explodingKittens.png", Vec2f(409, 585), 52, 0.3f);

	Card(u16 index, Vec2f position, float rotation = 0, bool flipped = false)
	{
		this.index = index;
		this.position = position;
		this.targetPosition = position;
		this.rotation = rotation;
		this.targetRotation = rotation;
		this.flipped = flipped;
		this.flip = flipped ? 1 : 0;
	}

	Card(CBitStream@ bs)
	{
		index = bs.read_u16();
		position.x = bs.read_f32();
		position.y = bs.read_f32();
		targetPosition = position;
		rotation = bs.read_f32();
		targetRotation = rotation;
		flipped = bs.read_bool();
		flip = flipped ? 1 : 0;
	}

	private void EaseIntoPosition()
	{
		CRules@ rules = getRules();

		if (Grab::isGrabbing(this))
		{
			Vec2f mousePos = getControls().getInterpMouseScreenPos();
			Vec2f offset = rules.get_Vec2f("grab_offset");
			position = mousePos - offset;
		}
		else
		{
			position += (targetPosition - position) * easing;
		}

		flip += (flipped ? 1 - flip : -flip) * easing;

		rotation += angleDifference(targetRotation, rotation) * easing;
	}

	bool contains(Vec2f point)
	{
		Vec2f halfDim = deck.cardDim / 2 * deck.scale;
		return (
			point.x >= position.x - halfDim.x &&
			point.x <= position.x + halfDim.x &&
			point.y >= position.y - halfDim.y &&
			point.y <= position.y + halfDim.y
		);
	}

	void Flip()
	{
		flipped = !flipped;
	}

	void Render()
	{
		EaseIntoPosition();

		float[] matrix;
		Matrix::MakeIdentity(matrix);
		Matrix::SetTranslation(matrix, position.x, position.y, 0);
		Matrix::SetRotationDegrees(matrix, 0, 0, rotation);
		Render::SetModelTransform(matrix);

		Vertex[] vertices = deck.getVertices(this);

		Render::RawQuads(deck.sprite, vertices);
	}

	void Serialize(CBitStream@ bs)
	{
		bs.write_u16(index);
		bs.write_f32(position.x);
		bs.write_f32(position.y);
		bs.write_f32(rotation);
		bs.write_bool(flipped);
	}
}
