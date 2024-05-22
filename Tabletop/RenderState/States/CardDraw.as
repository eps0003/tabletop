#include "RenderState.as"
#include "LerpTimer.as"

class CardDraw : RenderState
{
	private Game@ game;
	private LerpTimer@ timer;

	private u16 card;

	private dictionary@ renderCards;
	private RenderCard@ renderCard;
	private RenderCard renderCardStart;

	CardDraw(Game@ game, dictionary@ renderCards)
	{
		@this.game = game;
		@this.renderCards = renderCards;
		@timer = LerpTimer(0.4f);
	}

	void Start()
	{
		// Draw a card
		card = game.drawCard();

		// Get the rendered card
		renderCards.get("" + Card::clean(card), @renderCard);

		// Copy the current state of the rendered card
		renderCardStart = renderCard;

		// Hide the rendered card during the animation
		renderCard.Hide();

		// Start the timer
		timer.Start();
	}

	void Render()
	{
		float time = 1 - Maths::Pow(1 - timer.getTime(), 2); // Ease out

		Vec2f position = Vec2f_lerp(renderCardStart.getPosition(), renderCard.getPosition(), time);
		float angle = renderCard.getAngle(); // TODO
		float scale = Maths::Lerp(renderCardStart.getScale(), renderCard.getScale(), time);

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
