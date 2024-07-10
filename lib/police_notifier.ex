defmodule PoliceNotifier do
  use Dotenvy

  @geolocation_api_key env!("GEOLOCATION_API_KEY")
  @police_api_key env!("POLICE_API_KEY")
  @twilio_account_sid env!("TWILIO_ACCOUNT_SID")
  @twilio_auth_token env!("TWILIO_AUTH_TOKEN")
  @whatsapp_from env!("WHATSAPP_FROM")
  @whatsapp_to env!("WHATSAPP_TO")

  def get_location do
    url = "https://www.googleapis.com/geolocation/v1/geolocate?key=#{@geolocation_api_key}"
    body = Jason.encode!(%{})

    case HTTPoison.post(url, body, [{"Content-Type", "application/json"}]) do
      {:ok, %HTTPoison.Response{body: response_body}} ->
        {:ok, %{"location" => location}} = Jason.decode(response_body)
        location

      {:error, %HTTPoison.Error{reason: reason}} ->
        {:error, reason}
    end
  end

  def get_police_activity(lat, lng) do
    # Assume we have a police activity API endpoint that accepts latitude and longitude
    url = "https://api.policeactivity.com/alerts?lat=#{lat}&lng=#{lng}&apikey=#{@police_api_key}"

    case HTTPoison.get(url) do
      {:ok, %HTTPoison.Response{body: response_body}} ->
        {:ok, %{"incidents" => incidents}} = Jason.decode(response_body)
        incidents

      {:error, %HTTPoison.Error{reason: reason}} ->
        {:error, reason}
    end
  end

  def send_whatsapp_message(body) do
    client = Twilio.Client.new(@twilio_account_sid, @twilio_auth_token)

    Twilio.Message.create(
      client,
      to: @whatsapp_to,
      from: @whatsapp_from,
      body: body
    )
  end

  def notify_if_police_activity do
    case get_location() do
      {:ok, %{"lat" => lat, "lng" => lng}} ->
        case get_police_activity(lat, lng) do
          incidents when length(incidents) > 0 ->
            send_whatsapp_message("Police activity reported in your area: #{hd(incidents)["description"]}")

          _ ->
            IO.puts("No police activity reported in your area.")
        end

      {:error, reason} ->
        IO.puts("Failed to get location: #{reason}")
    end
  end
end

PoliceNotifier.notify_if_police_activity()
