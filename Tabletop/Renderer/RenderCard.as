class RenderCard
{
	private u16 card;

	private Vec2f position = Vec2f_zero;
	private float angle = 0.0f;
	private Vec2f scale = Vec2f_zero;

	private bool visible = true;

	RenderCard(u16 card)
	{
		this.card = card;
	}

	u16 getCard()
	{
		return card;
	}

	void SetPosition(Vec2f position)
	{
		this.position = position;
	}

	Vec2f getPosition()
	{
		return position;
	}

	void SetAngle(float angle)
	{
		this.angle = angle;
	}

	float getAngle()
	{
		return angle;
	}

	void SetScale(Vec2f scale)
	{
		this.scale = scale;
	}

	Vec2f getScale()
	{
		return scale;
	}

	void Hide()
	{
		visible = false;
	}

	void Show()
	{
		visible = true;
	}

	bool isVisible()
	{
		return visible;
	}

	void Render()
	{
		if (!visible) return;

		DrawCard(card, position, angle, scale);
	}
}
