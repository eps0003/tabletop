shared class Card
{
	private float easing = 0.1f;

	Vec2f position;
	Vec2f targetPosition;

	float rotation;
	float targetRotation;

	Vec2f dim(100, 160);

	Card(Vec2f position, float rotation = 0)
	{
		this.position = position;
		this.targetPosition = position;
		this.rotation = rotation;
		this.targetRotation = rotation;
	}

	private void EaseIntoPosition()
	{
		position += (targetPosition - position) * easing;
	}

	void Render()
	{
		EaseIntoPosition();

		Vec2f halfDim = dim / 2;
		GUI::DrawRectangle(position - halfDim, position + halfDim, color_white);
	}
}
