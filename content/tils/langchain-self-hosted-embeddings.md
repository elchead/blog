---
title: LangChain's Quirks with Self-Hosted Embeddings
taxonomies:
  tags:
    - ""
date: 2023-10-13
---
While integrating a self-hosted embeddings model with LangChain, which I hosted through Hugging Face's [Text Embedding Inference (TEI)](https://github.com/huggingface/text-embeddings-inference), I encountered an issue where the `OpenAIEmbeddings` client automatically tokenized my input using the OpenAI model tokenizer. This wasn’t a compatibility issue, but it confused me with very poor results because the wrong tokenizer was applied without warning.

### **The Problem**

I assumed that I could use the `OpenAIEmbeddings` client with my self-hosted inference server, as it exposes an OpenAI-compatible API. However, LangChain's `OpenAIEmbeddings` client has a **default setting** that enables **client-side tokenization** using the `tiktoken` library. This behavior is controlled by the `tiktoken_enabled` parameter, which is set to `True` by default.

### **Non-Working Code: OpenAIEmbeddings Client**

This is the code I initially used, expecting it to work with my self-hosted server:

```
from langchain_openai import OpenAIEmbeddings

client = OpenAIEmbeddings(
    base_url="http://localhost:80/v1",
)
```

However, **this does not work efficiently** because LangChain assumes that the OpenAI model tokenizer should be used. Since my self-hosted model was not OpenAI’s model, the **wrong tokenizer was applied, resulting in poor performance**.

### **Crucial Issue: Tokenization is Enabled by Default**

By default, `tiktoken_enabled=True`, meaning LangChain will tokenize the input before sending it to the API:

```
client = OpenAIEmbeddings(
    base_url="http://localhost:80/v1",
    tiktoken_enabled=True  # This is the default setting causing the issue
)
```

Even when setting `tiktoken_enabled=False`, LangChain still tries to load a tokenizer for the model, though it does not include the tokenized output in the request. This means it will require an additional dependency for tokenizing the input of a custom model, which seemed unnecessary for my use case.

### **The Solution: Use HuggingFaceEndpointEmbeddings Instead**

I found that using `HuggingFaceEndpointEmbeddings` was a better approach, as it allows specifying a custom endpoint without automatic tokenization:

```
from langchain_huggingface.embeddings import HuggingFaceEndpointEmbeddings

client = HuggingFaceEndpointEmbeddings(model="http://localhost:80")
```

This bypassed the incorrect tokenization and aligned with my server’s expectations.

### **Documentation Gaps & Lessons Learned**

While exploring LangChain’s embedding clients, I expected a more suitable option for self-hosted models. However:

- All alternative clients did not **explicitly** support custom URLs.
    
- The `HuggingFaceEndpointEmbeddings` client seemed designed for official Hugging Face endpoints, but it actually supports specifying a custom URL via the model parameter—which was not documented.
    
- I **only discovered this via AI assistance**, which suggested trying the `model` parameter for specifying the endpoint.
    

### **Key Takeaways**

- LangChain’s `OpenAIEmbeddings` client applies tokenization by default, so only use it for OpenAIs embedding models
    
- Using `HuggingFaceEndpointEmbeddings` is a better approach for self-hosted models through HF text-embedding-inference
    
- **LangChain documentation is incomplete** in some areas, and AI assistance can sometimes provide better insights than the official docs.
    

### **Final Thoughts**

If you’re hosting your own embeddings model, double-check how LangChain processes input before making API calls. The wrong tokenizer can silently degrade performance without errors, making troubleshooting difficult.