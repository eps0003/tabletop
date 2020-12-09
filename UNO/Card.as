shared class Card
{
	private float easing = 0.08f;

	u16 index;

	Vec2f position;
	Vec2f targetPosition;

	float rotation;
	float targetRotation;

	float flip;
	bool flipped;

	Vec2f dim(140, 190);

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
	}

	private void EaseIntoPosition()
	{
		position += (targetPosition - position) * easing;

		flip += (flipped ? 1 - flip : -flip) * easing;
	}

	bool contains(Vec2f point)
	{
		Vec2f halfDim = dim / 2;
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

		Vec2f halfDim = dim / 2;
		halfDim.x *= xScale;

		string sprite = flip > 0.5f ? "playingCards.png" : "playingCardBacks.png";
		u16 i = flip > 0.5f ? index : 0;

		GUI::DrawIcon(sprite, i, dim, position - halfDim, 0.5f * xScale, 0.5f, color_white);
	}

	void Serialize(CBitStream@ bs)
	{
		bs.write_u16(index);
	}
}
