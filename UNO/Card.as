shared class Card
{
	private float easing = 0.05f;

	Vec2f position;
	Vec2f targetPosition;

	float rotation;
	float targetRotation;

	SColor color;

	Vec2f dim(100, 160);

	Card(Vec2f position, float rotation = 0)
	{
		this.position = position;
		this.targetPosition = position;
		this.rotation = rotation;
		this.targetRotation = rotation;

		this.color = SColor(255, XORRandom(256), XORRandom(256), XORRandom(256));
	}

	private void EaseIntoPosition()
	{
		position += (targetPosition - position) * easing;
	}

	void Render()
	{
		EaseIntoPosition();

		Vec2f halfDim = dim / 2;
		GUI::DrawRectangle(position - halfDim, position + halfDim, color);
	}
}
