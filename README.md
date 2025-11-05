# ⚡ SimuPower — AI Energy Visualization for MATLAB

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Repo Size](https://img.shields.io/github/repo-size/ItsJacovJS/SimuPower)](https://github.com/ItsJacovJS/SimuPower)
[![Stars](https://img.shields.io/github/stars/ItsJacovJS/SimuPower?style=social)](https://github.com/ItsJacovJS/SimuPower)

> 💡 *SimuPower turns MATLAB simulations into real-time, AI-generated schematic visuals.*  
> Now available in **two separate builds** — powered by **ChatGPT (OpenAI)** and **Cloudflare AI Gateway**.

---

## 🌐 Two Versions — Your Choice, Your Power

| Version | API Source | Cost | Description |
|----------|-------------|------|--------------|
| 🧠 **SimuPower (ChatGPT Edition)** | OpenAI’s `gpt-image-1` model | 💰 Paid API credits required | High-quality, direct integration with OpenAI’s API. |
| ☁️ **SimuPower (Cloudflare Edition)** | Cloudflare AI Gateway endpoint | 🆓 Free / low-cost | Uses Cloudflare proxy routing for affordable image generation. |

> ⚙️ Both editions simulate the same energy data — they only differ in how images are generated.  
> Choose **ChatGPT Edition** for top quality, or **Cloudflare Edition** if you’re on a tight budget.

*📝 Note: There is also a DeepAI version but it has not yet been polished, use at your own risk*

---

## 📁 Repository Structure

```bash
SimuPower/
├── Simulator/
│ └── Cloudflare Edition/  
│   └── simupower.m
│ └── ChatGPT Edition/
│   └── simupower.m
```

## ⚙️ Overview

**SimuPower** combines energy simulation and AI visualization to create smart, schematic-style circuit images.  
It estimates appliance energy use, cost, and displays a generated image directly inside **MATLAB’s App Designer UI**.

---

## ✨ Features

### ✅ Two Independent Editions
- 🧠 **simupower.m** *(ChatGPT)* — OpenAI-powered (premium image generation, higher quality)
- ☁️ **simupower.m** *(CloudFare)* — Cloudflare-proxied (free alternative for budget users)

> 💡 *These are two separate files! Choose your edition based on your needs or budget.*

### ⚡ Dynamic Cost Simulation
Calculates energy cost based on:
- Appliance wattage  
- Usage hours  
- Time frame *(Daily / Weekly / Monthly)*  

### 🧩 AI-Generated Visuals
Creates schematic circuit diagrams of selected appliances using AI-generated prompts.

### 🧱 Error-Handled API Calls
Graceful handling of:
- Billing or quota issues  
- API key errors  
- Failed Cloudflare endpoints  

### 🔌 Offline Fallback
When no API is available, the simulation continues without image generation.

---

## 🧮 How It Works

1. Select which edition you want to run.
2. Choose appliances and duration.  
3. MATLAB simulates energy use and cost.  
4. The app sends a text prompt to your chosen AI API.  
5. The generated schematic is displayed in real time inside MATLAB.

---

## 🧠 ChatGPT Edition Setup (💰 Paid / Premium Option)

🔥 **Best for maximum image quality and precision.**

1. Open `ChatGPT Edition/simupower.m` in MATLAB.  
2. Add your OpenAI API key inside the code:

   ```matlab
   apiKey = "sk-proj-xxxx";
   url = "https://api.openai.com/v1/images/generations";
   ```
3. Run the app.  
4. Select your appliances — the app will use OpenAI’s `gpt-image-1` model to generate visuals.

### Example MATLAB Request

```matlab
body = struct( ...
    'model', 'gpt-image-1', ...
    'prompt', desc, ...
    'size', '1024x1024' ...
);

req = RequestMessage('post', headers, MessageBody(body));
resp = req.send(url);
```

If the OpenAI quota or billing limit is reached, MATLAB displays:

> ⚠️ “Your OpenAI billing limit or quota has been reached.  
> Please check your API usage on the OpenAI dashboard.”

---

## ☁️ Cloudflare Edition Setup (🆓 Budget Option)

💸 **Perfect for students, hobbyists, or users under budget constraints.**

1. Open `Cloudflare Edition/simupower.m` in MATLAB.  
2. Replace the endpoint and API key:

   ```matlab
   apiKey = "cf-key-xxxx";
   url = "https://your-endpoint.workers.dev/v1/images/generations";
   ```
3. Run the app — visuals are generated through your Cloudflare Worker proxy.

💬 *Image quality and speed may vary depending on your Cloudflare setup — but it’s completely free!*

---

## 📸 Snapshots

![App UI](https://github.com/ItsJacovJS/SimuPower/blob/main/images/snapshot_1.jpg)

| 🧠 ChatGPT Edition | ☁️ Cloudflare Edition |
|--------------------|----------------------|
| ![ChatGPT Edition](https://github.com/ItsJacovJS/SimuPower/blob/main/images/snapshot_2.png) | ![Cloudflare Edition](https://github.com/ItsJacovJS/SimuPower/blob/main/images/snapshot_3.png) |

> Both editions visualize the same simulation — just powered by different APIs.

---

## 🛠 Requirements

- MATLAB R2023a or later *(works on MATLAB Online)*  
- App Designer Toolbox  
- One of:  
  - ✅ **OpenAI API key** (for ChatGPT Edition)  
  - ✅ **Cloudflare Worker or Gateway endpoint** (for Cloudflare Edition)

---

## 💡 Tips & Best Practices

🧠 Use **ChatGPT Edition** for higher accuracy and faster AI rendering.  
☁️ Use **Cloudflare Edition** if you want to avoid OpenAI API costs.  
🔄 Keep both versions — you can switch anytime without reconfiguring MATLAB.  
💾 Make sure your API key and endpoint are securely stored and **not committed to GitHub**.

---

## 🧾 License

**MIT License © 2025**  
Created with ⚡ and ❤️ by **ItsJacovJS**
