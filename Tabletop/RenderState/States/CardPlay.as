#include "RenderState.as"

class CardPlay : RenderState
{
	private Game@ game;
	private LerpTimer@ timer;

	private string player;
	private u16 card;

	private dictionary@ renderCards;
	private RenderCard@ renderCard;
	private RenderCard renderCardStart;

	CardPlay(Game@ game, dictionary@ renderCards, string player, u16 card)
	{
		@this.game = game;
		this.player = player;
		this.card = card;
		renderCards.get("" + Card::clean(card), @renderCard);
		@timer = LerpTimer(0.4f);
	}

	void Start()
	{
		game.PlayCard(player, card);

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
