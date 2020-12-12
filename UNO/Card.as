#include "Grab.as"
#include "Deck.as"
#include "Utilities.as"
#include "DeckManager.as"

class Card
{
	private float easing = 0.07f;

	Deck@ deck;
	u16 index;

	Vec2f position;
	Vec2f targetPosition;

	float rotation;
	float targetRotation;

	float flip;
	bool flipped;
	bool hidden = false;

	Card(Deck@ deck, u16 index, Vec2f position, float rotation = 0, bool flipped = false)
	{
		@this.deck = deck;
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
		@deck = Deck::Deserialize(bs);
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
		Vec2f alignedPoint = point.RotateBy(-rotation, position);
		Vec2f halfDim = deck.cardDim / 2 * deck.scale;
		return (
			alignedPoint.x >= position.x - halfDim.x &&
			alignedPoint.x <= position.x + halfDim.x &&
			alignedPoint.y >= position.y - halfDim.y &&
			alignedPoint.y <= position.y + halfDim.y
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
		deck.Serialize(bs);
	}
}
