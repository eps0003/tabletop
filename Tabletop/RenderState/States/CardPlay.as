#include "RenderState.as"

class CardPlay : RenderState
{
	private Game@ game;

	private CPlayer@ player;
	private u16 card;

	private dictionary@ renderCards;
	private RenderCard@ renderCard;
	private RenderCard renderCardStart;

	private uint gameTime = 0.0f;

	private float time
    {
		get const
		{
			if (gameTime == 0.0f)
			{
				return 0.0f;
			}

			float duration = getTicksASecond() * 0.4f; // 1 second
			float t = Maths::Clamp01((getGameTime() - gameTime) / duration);
			return 1 - Maths::Pow(1 - t, 2); // Ease out
		}
	}

	CardPlay(Game@ game, dictionary@ renderCards, CPlayer@ player, u16 card)
	{
		@this.game = game;
		@this.player = player;
		this.card = card;
		renderCards.get("" + Card::clean(card), @renderCard);
	}

	void Start()
	{
		game.PlayCard(player, card);

		// Copy the current state of the rendered card
		renderCardStart = renderCard;

		// Hide the rendered card during the animation
		renderCard.Hide();

		// Store the current game time
		gameTime = getGameTime();
	}

	void Render()
	{
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
		return time >= 1.0f;
	}
}
