#include "Grab.as"

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

	//standard playing cards
	Vec2f dim(140, 190);
	float scale = 1.0f;

	// //exploding kittens
	// Vec2f dim(409, 585);
	// float scale = 0.3f;

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

		rotation += (targetRotation - rotation) * easing;
	}

	bool contains(Vec2f point)
	{
		Vec2f halfDim = dim / 2 * scale;
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

		float xScale = Maths::Abs(flip - 0.5f) * 2;

		Vec2f halfDim = dim / 2.0f * scale;
		halfDim.x *= xScale;

		string sprite = flip > 0.5f ? "playingCards.png" : "playingCardBacks.png";
		u16 i = flip > 0.5f ? index : 0;

		// // string sprite = "explodingKittensCards.png";
		// // u16 i = flip > 0.5f ? index : 69;

		Vec2f imageDim;
		GUI::GetImageDimensions(sprite, imageDim);

		float w = imageDim.x / dim.x;
		float h = imageDim.y / dim.y;

		Vec2f u(i % int(w) / w, i / int(w) / h);
		Vec2f v = u + Vec2f(1.0f / w, 1.0f / h);

		Vertex[] vertices = {
			Vertex( halfDim.x, -halfDim.y, 0, v.x, u.y, color_white),
			Vertex( halfDim.x,  halfDim.y, 0, v.x, v.y, color_white),
			Vertex(-halfDim.x,  halfDim.y, 0, u.x, v.y, color_white),
			Vertex(-halfDim.x, -halfDim.y, 0, u.x, u.y, color_white)
		};

		float[] matrix;
		Matrix::MakeIdentity(matrix);
		Matrix::SetTranslation(matrix, position.x, position.y, 0);
		Matrix::SetRotationDegrees(matrix, 0, 0, rotation);
		Render::SetModelTransform(matrix);

		Render::RawQuads(sprite, vertices);
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
