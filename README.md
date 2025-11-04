# ⚡ SimuGrid (MATLAB + OpenAI)

SimuGrid automatically generates **schematic visualizations** of connected appliances using **OpenAI’s image generation API**.
It combines real-time **energy consumption simulation** with **AI-powered infographic rendering** — turning your data into elegant, educational visuals.

---

## 🎯 Features

✅ **AI-Powered Visualization**
Automatically generates schematic circuit-style images of selected appliances using OpenAI’s `gpt-image-1` model.

✅ **Dynamic Cost Simulation**
Calculates estimated electricity cost based on:

* Appliance wattage
* Usage hours
* Time frame *(Daily / Weekly / Monthly)*

✅ **Interactive UI**
Built with MATLAB App Designer — includes dropdown menus, list boxes, live image panels, and real-time billing labels.

✅ **Error & Billing Handling**

* Graceful fallback if API call fails
* Friendly alert when billing or quota limits are reached
* Clean log warnings (no crashes)

---

## 🧠 How It Works

1. Select appliances from the list.
2. Choose how many and for how long they’ll run.
3. The app:

   * Computes energy use and cost
   * Sends a **descriptive text prompt** to OpenAI’s image generation API
   * Displays the generated circuit diagram right inside the MATLAB app

---

## 🧩 Core Function: `updateSimulation(app)`

This function:

* Manages UI elements (images, labels)
* Builds descriptive prompts for OpenAI
* Handles all network communication and errors

```matlab
body = struct( ...
    'model', 'gpt-image-1', ...
    'prompt', desc, ...
    'size', '1024x1024' ...
);

req = RequestMessage('post', headers, MessageBody(body));
resp = req.send(url);
```

If the OpenAI quota or billing limit is reached, the app displays:

> ⚠️ “Your OpenAI billing limit or quota has been reached.
> Please check your plan and billing details on the OpenAI dashboard.”

---

## 🛠️ Requirements

* MATLAB R2023a or later *(works on MATLAB ONLINE as well)*
* **App Designer Toolbox**
* Valid [OpenAI API key](https://platform.openai.com/api-keys)
* Active billing plan on OpenAI

---

## 🚀 Setup

1. Clone or download this repository.
2. Open the `.m` file in MATLAB App Designer.
3. Replace the placeholder API key:

   ```matlab
   apiKey = 'sk-proj-xxxx';
   ```
4. Run the app — select appliances and visualize your AI-generated circuit.

---

## 📸 Snapshot
![SimuGrid Simulation](https://github.com/ItsJacovJS/SimuPower/blob/main/images/snapshot_1.jpg)

*(Image generated via OpenAI `gpt-image-1`)*

![AI Sample Prompt](https://github.com/ItsJacovJS/SimuPower/blob/main/images/snapshot_2.png)

---

## 🧾 License

MIT License © 2025
Created with ❤️ by ItJacovJS

---

> 💡: You can extend this project with MatGPT or integrate ChatGPT-5 for real-time troubleshooting or design suggestions right inside MATLAB!
