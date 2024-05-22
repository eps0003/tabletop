#include "RenderState.as"
#include "LerpTimer.as"

class CardLerp : RenderState
{
	private Game@ game;
	private RenderCard@ renderCard;
	private RenderCard renderCardStart;
	private LerpTimer@ timer;

	CardLerp(Game@ game, RenderCard@ renderCard)
	{
		@this.game = game;
		@this.renderCard = renderCard;
		@timer = LerpTimer(0.4f);
	}

	void Start()
	{
		renderCardStart = renderCard;
		renderCard.Hide();
		timer.Start();
	}

	void Render()
	{
		float time = 1 - Maths::Pow(1 - timer.getTime(), 2); // Ease out

		u16 card = renderCard.getCard();
		Vec2f position = Vec2f_lerp(renderCardStart.getPosition(), renderCard.getPosition(), time);
		float angle = renderCard.getAngle(); // TODO
		Vec2f scale = Vec2f_lerp(renderCardStart.getScale(), renderCard.getScale(), time);

		DrawCard(card, position, angle, scale);
	}

	void End()
	{
		renderCard.Show();
	}

	bool isComplete()
	{
		return timer.isComplete();
	}
}
