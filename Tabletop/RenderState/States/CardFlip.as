#include "RenderState.as"
#include "LerpTimer.as"

class CardFlip : RenderState
{
	private Game@ game;
	private RenderCard@ renderCard;
	private bool reveal;
	private LerpTimer@ timer;

	CardFlip(Game@ game, RenderCard@ renderCard, bool reveal)
	{
		@this.game = game;
		@this.renderCard = renderCard;
		this.reveal = reveal;
		@timer = LerpTimer(0.4f);
	}

	void Start()
	{
		timer.Start();
		renderCard.Hide();
	}

	void Render()
	{
		float time = timer.getTime();
		float scaleX = Maths::Abs(Maths::Cos(time * Maths::Pi));

		u16 card = reveal ^^ time < 0.5f ? renderCard.getCard() : 0;

		Vec2f position = renderCard.getPosition();
		float angle = renderCard.getAngle();
		Vec2f scale = Vec2f(
			renderCard.getScale().x * scaleX,
			renderCard.getScale().y
		);

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
