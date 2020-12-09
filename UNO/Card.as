shared class Card
{
	private float easing = 0.05f;

	Vec2f position;
	Vec2f targetPosition;

	float rotation;
	float targetRotation;

	float flip;
	bool flipped;

	SColor color;

	Vec2f dim(100, 160);

	Card(Vec2f position, float rotation = 0, bool flipped = false)
	{
		this.position = position;
		this.targetPosition = position;
		this.rotation = rotation;
		this.targetRotation = rotation;
		this.flipped = flipped;
		this.flip = flipped ? 1 : 0;

		this.color = SColor(255, XORRandom(256), XORRandom(256), XORRandom(256));
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

		Vec2f halfDim = dim / 2;
		halfDim.x *= Maths::Abs(flip - 0.5f) * 2;
		SColor c = flip < 0.5f ? color : SColor(255, 100, 100, 100);
		GUI::DrawRectangle(position - halfDim, position + halfDim, c);
	}
}
