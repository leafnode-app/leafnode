defmodule LeafNode.Integrations.OpenAi.Gpt do
  @moduledoc """
    Module for helper methods accessing Open AI interaction
  """
  require Logger
  @timeout 30_000

  # NOTE - prompt pillars
  # [task]
  # [context]
  # [exemplar]
  # [persona]
  # [format]
  # [tone]

  # Context needs to be sumarized? beginning and end is higher prio to LLM
  # Bring in a third person? Name so that its you doing things for a user (So that the system, the assistant and me are helping user X)
  # Maybe add the context as messages and not add it to the body of the pompt? (Email threaded data)
  # Make sure to bring the LLM back to main question, after context says something like "Now that we have context, help me answer the question" etc

  @doc """
    Send through the payload and a string of process or what you want to process against the payload
  """
  def prompt(question, data, :node) do
    if !is_nil(config(:token)) do
      body_payload =
        Map.put(
          model_settings(),
          "messages",
          [
            %{
              "role" => "system",
              "content" => query_node(question, data)
            }
          ]
        )

      {status, resp} =
        HTTPoison.post(
          config(:completions_url),
          Jason.encode!(body_payload),
          [
            {"Content-type", "application/json"},
            {"Authorization", "Bearer #{config(:token)}"}
          ],
          recv_timeout: @timeout
        )

      case status do
        :ok -> handle_response(resp)
        :error -> {:error, "There was an error: #{resp}"}
      end
    else
      {:error, "There was an error getting the OPEN_AI key, check env variables"}
    end
  end

  def prompt(payload, user_id, :assistant) do
    if !is_nil(config(:token)) do
      body_payload =
        Map.put(
          model_settings(),
          "messages",
          [
            %{
              "role" => "system",
              "content" => query_assistant(payload, user_id)
            }
          ]
        )

      {status, resp} =
        HTTPoison.post(
          config(:completions_url),
          Jason.encode!(body_payload),
          [
            {"Content-type", "application/json"},
            {"Authorization", "Bearer #{config(:token)}"}
          ],
          recv_timeout: @timeout
        )

      case status do
        :ok -> handle_response(resp)
        :error -> {:error, "There was an error: #{resp}"}
      end
    else
      {:error, "There was an error getting the OPEN_AI key, check env variables"}
    end
  end

  # Handle the success reponse and its codes that came back from the HTTP post
  defp handle_response(resp) do
    case resp.status_code do
      200 ->
        resp = Jason.decode!(resp.body)
        {_status, data} = return_choice_by_index(resp, 0)
        {:ok, Jason.decode!(data)}

      _ ->
        {
          :error,
          "There was an error: #{Jason.decode!(resp.body)}"
        }
    end
  end

  # Take in a list of choiced from a response and return the index
  defp return_choice_by_index(choices, index) do
    {_tag, data} = Enum.at(choices, index)
    {:ok, Enum.at(data, 0) |> Map.get("message") |> Map.get("content")}
  end

  @doc """
    The prompt function that we can call to get the prompt
  """
  defp query_node(question, data) do
    """
    Please provide a valid JSON output.

    **You will be given:**
    - **Question**: A specific question posed by the assistant on behalf of the user.
    - **Data**: A list of information associated with the topic, typically extracted from connected resources like Notion pages.

    ---

    **Your Task:**
    Formulate an answer to the question using **only** the provided data. Follow these guidelines when crafting your response.

    ---
    ### **Guidelines:**

    1. **Using the Provided Data:**
      - Base your answer solely on the data provided. **Do not include information that is not present in the data.**
      - Ensure that your answer directly addresses the question.

    2. **When Data is Sufficient:**
      - Provide a clear and concise answer using the data.
      - Organize the information logically, using bullet points or numbered lists if appropriate.

      **Example:**
      - **Question:** "What are my upcoming appointments?"
      - **Data:**

        ```json
        [
          "Dentist appointment on Friday at 10 AM.",
          "Call Mom on Sunday.",
          "Renew gym membership by the end of the month."
        ]
        ```
      - **Response:**
        ```json
        {
          "message": "Your upcoming appointments are:\n- Dentist appointment on Friday at 10 AM.\n- Call Mom on Sunday.\n- Renew gym membership by the end of the month."
        }
        ```

    3. **When Data is Insufficient or Not Relevant:**
      - Politely inform the user that the data does not contain the information needed to answer the question fully.
      - Suggest that they add or connect relevant data in the LeafNode app for a more comprehensive answer.
      - **Do not fabricate information** or provide answers based on external knowledge.

      **Example:**
      - **Question:** "What is the budget allocation for the marketing campaign?"
      - **Data:** (No relevant information)
      - **Response:**
        ```json
        {
          "message": "I'm sorry, but I don't have information about the budget allocation for the marketing campaign. Please consider adding relevant data to your nodes so I can assist you better."
        }
        ```

    4. **Avoiding General Knowledge Answers:**
      - Do not provide general knowledge answers that are not based on the provided data.
      - Focus on the user's data, and if it's not sufficient, guide them to provide more.

    5. **Response Formatting:**
      - Always return a JSON object with one field:
        - `"message"`: A string containing your response to the user.

    6. **Politeness and Clarity:**
      - Maintain a polite and professional tone.
      - Be clear and concise in your wording.

    7. **Do Not Change Topics:**
      - Stay focused on the question asked.
      - Do not introduce new topics or include irrelevant information.

    8. **Important Notes:**
      - **Accuracy is paramount**: Ensure that your answer is correct and based solely on the provided data.
      - **Do not make assumptions** beyond the provided data.
      - **Follow instructions carefully** to provide the best assistance.

    ---
    **Input Data:**
    #{Jason.encode!(data)}

    ---
    **Question:** #{question}
    """
  end

  @doc """
    Query the assistant to get the nodes and the question if applicable
  """
  defp query_assistant(payload, user_id) do
    """
   Please provide a valid JSON output.

    **You will be given:**
    - **Conversation Thread**: A list of messages representing a conversation between you and the user. The latest message is at the top, with earlier messages following. Use the latest message as your primary focus and the earlier messages as context when necessary.
    - **Nodes List**: A list of nodes, each containing a **title**, **description**, and **id**. These nodes represent topics or data sources that the user has set up.

    ---
    **Your Task:**
    Analyze the user's latest message and, considering the conversation context and the nodes available, produce an appropriate response following these guidelines.

    ---

    ### Guidelines:
    1. **Greetings and Farewells:**
      - If the user's latest message is a greeting, such as "Hello," "Hi," or similar, respond politely and concisely without adding any additional information or prompts.
        - Example:
          ```json
          {
            "message": "Hello! How can I assist you today?",
            "node": null
          }
          ```
      - If the user's latest message is a farewell, such as "Goodbye," "See you later," or similar, respond politely and wish them well.
        - Example:
          ```json
          {
            "message": "Goodbye! Have a great day!",
            "node": null
          }
          ```
      - If the user expresses gratitude, such as "Thank you," "Thanks," or similar, acknowledge it politely.
        - Example:
          ```json
          {
            "message": "You're welcome! Let me know if there's anything else you need.",
            "node": null
          }
          ```
      - Do not include any additional prompts, reminders, or instructions about setting up nodes or providing more information in these cases.

      2. **Identifying Relevant Nodes:**
      - Determine if a relevant node exists that directly matches the user's request, based on a clear and strong match between the user's message (and context) and the node's title and description.
      - Consider the entire conversation context, especially if the latest message is ambiguous. Use earlier messages to understand the user's intent.
        - When the latest message is ambiguous, prioritize nodes that closely match the user's request based on the entire conversation.
      - Only select a node if there is a direct and unambiguous relevance. Avoid loose associations or assumptions based on keywords alone.
        - Avoid selecting nodes based on partial keyword matches or indirect associations.

    3. **Formulating a Response When a Relevant Node is Found:**
      - Formulate a question that could be asked of that node to obtain an answer.
      - **Response Format:**

        ```json
        {
          "message": "[Formulated question based on the user's input and the relevant node]",
          "node": "[Relevant Node ID]"
        }
        ```
      - Example:
        - User's Latest Message: "Could you give me the latest updates on Project Alpha?"
        - Assistant's Response:
          ```json
          {
            "message": "What are the detailed progress reports and milestones for Project Alpha?",
            "node": "Node_ID_for_Project_Alpha_Updates"
          }
          ```

    4. **Formulating a Response When No Relevant Node is Found or Request is Unclear:**
      - Politely inform the user that more information is needed or that they may need to add relevant nodes and connect necessary data.
      - Encourage the user to provide more details or clarify their request.
      - **Response Format:**
        ```json
        {
          "message": "[Polite message indicating the need for more information or suggesting to add relevant nodes]",
          "node": null
        }
        ```
      - Example:
        - User's Latest Message: "Do we have any updates on the new product launch?"
        - Assistant's Response:
          ```json
          {
            "message": "I'm sorry, but I don't have any information on the new product launch. Please consider adding a relevant node or providing more details so I can assist you better.",
            "node": null
          }
          ```

    5. **Handling Ambiguity and Uncertainty:**
      - If uncertain about which node is most relevant, do not make assumptions.
      - Politely ask for clarification if needed.
      - Example:
        - User's Latest Message: "What's the status?"
        - Assistant's Response:
          ```json
          {
            "message": "Could you please specify which project or topic you're referring to so I can assist you better?",
            "node": null
          }
          ```

    6. **Response Style Guidelines:**
      - Keep your response concise, ideally under 150 words.
      - Maintain a polite and professional tone in all responses.
      - Avoid using slang or informal language.
      - Do not include unnecessary information, system-related instructions, or mentions of setting up nodes unless the user explicitly asks.

    7. **Response Formatting:**
      - Always return a JSON object with two fields:
        - `"message"`: A string containing your response to the user.
        - `"node"`: The ID of the relevant node if one is found, or `null` if not.

    8. **Important Notes:**
      - Accuracy is crucial: Only select a node if it clearly matches the user's request.
      - Do not make assumptions beyond the provided conversation and nodes.
      - Avoid loose associations: Do not match nodes based on vague or indirect connections.
      - Focus on user intent: Ensure that your response aligns with what the user is asking for.
      - If the Nodes List is empty or lacks relevant nodes, politely inform the user and suggest adding relevant nodes.
      - If the Conversation Thread is insufficient to determine the user's intent, politely ask for more information.

    ---
    **Conversation Thread:** #{Jason.encode!(payload)}
    **Nodes List:** #{Jason.encode!(get_nodes(user_id))}

    ---
    **Remember to follow these guidelines closely to provide the best assistance to the user.**
    **Important:** Only provide the JSON response as specified. Do not include any additional text, explanations, or notes.
   """
  end

  # Get the model settings for the prompt
  defp model_settings() do
    %{
      "temperature" => 0,
      "model" => config(:model),
      "response_format" => %{"type" => "json_object"}
    }
  end

  # Get user nodes
  defp get_nodes(user_id) do
    case LeafNode.Repo.Node.list_nodes(user_id) do
      {:ok, nodes} ->
        Enum.filter(nodes, fn node -> node.enabled end)
        |> Enum.map(fn node ->
          %{
            title: node.title,
            description: node.description,
            id: node.id
          }
        end)

      {:error, _err} ->
        Logger.error("No nodes to add")
        "Nothing found"
    end
  end

  # config to get based off the application name
  def config(), do: Application.get_env(:leaf_node, :open_ai)
  def config(key, default \\ nil), do: Keyword.get(config(), key, default)
end
