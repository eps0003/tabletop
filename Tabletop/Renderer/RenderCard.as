class RenderCard
{
	private u16 card;

	private Vec2f position = Vec2f_zero;
	private float angle = 0.0f;
	private float scale = 1.0f;

	private bool visible = true;

	RenderCard(u16 card)
	{
		this.card = card;
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

	void SetScale(float scale)
	{
		this.scale = scale;
	}

	float getScale()
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
