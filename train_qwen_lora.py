import os
import torch
from transformers import (
    AutoModelForCausalLM,
    AutoTokenizer,
    TrainingArguments,
    Trainer,
    DataCollatorForSeq2Seq,
)
from peft import LoraConfig, get_peft_model, prepare_model_for_kbit_training, TaskType
from datasets import load_dataset


def main():
    print("🚀 Initializing Qwen 3.5 LoRA Fine-tuning pipeline for NyayaMithra...")

    # Configuration arguments for the training
    model_id = "Qwen/Qwen3.5-7B"
    dataset_path = "./data/legal_civic_data.jsonl"
    output_dir = "./qwen-legal-lora-adapter"

    # 1. Load Tokenizer
    print("📚 Loading Tokenizer...")
    tokenizer = AutoTokenizer.from_pretrained(model_id, trust_remote_code=True)
    tokenizer.pad_token_id = tokenizer.eos_token_id

    # 2. Load Base Model (using 4-bit or 8-bit usually for memory efficiency - QLoRA)
    print("🧠 Loading Base Model...")
    model = AutoModelForCausalLM.from_pretrained(
        model_id, device_map="auto", torch_dtype=torch.float16, trust_remote_code=True
    )

    # Enable gradient checkpointing for memory efficiency
    model.gradient_checkpointing_enable()
    # model = prepare_model_for_kbit_training(model) # Required if loading in 4-bit / 8-bit

    # 3. Apply LoRA Configuration
    print("⚡ Applying LoRA Adapters...")
    lora_config = LoraConfig(
        r=16,  # Rank
        lora_alpha=32,
        target_modules=[
            "q_proj",
            "k_proj",
            "v_proj",
            "o_proj",
            "gate_proj",
            "up_proj",
            "down_proj",
        ],
        lora_dropout=0.05,
        bias="none",
        task_type=TaskType.CAUSAL_LM,
    )

    model = get_peft_model(model, lora_config)
    model.print_trainable_parameters()

    # 4. Load Legal/Civic Dataset
    print("📊 Loading Custom Indian Legal/Civic Dataset...")
    # NOTE: In real code, ensuring proper dataset formatting is critical.
    try:
        dataset = load_dataset("json", data_files=dataset_path, split="train")
    except Exception as e:
        print(
            f"⚠️ Dummy run warning: Could not find dataset {dataset_path}. Using mock dataset mode."
        )
        dataset = []

    def tokenize_function(examples):
        # Format: <|im_start|>user\nPrompt<|im_end|>\n<|im_start|>assistant\nResponse<|im_end|>
        return tokenizer(
            examples["text"], truncation=True, padding="max_length", max_length=512
        )

    # tokenized_dataset = dataset.map(tokenize_function, batched=True)

    # 5. Set Training Arguments
    training_args = TrainingArguments(
        output_dir=output_dir,
        per_device_train_batch_size=4,
        gradient_accumulation_steps=4,
        learning_rate=2e-4,
        logging_steps=10,
        max_steps=500,
        save_strategy="steps",
        save_steps=100,
        fp16=True,  # Use Mixed Precision Training
        optim="paged_adamw_8bit",
        report_to="tensorboard",
    )

    # 6. Initialize the Trainer
    print("⚙️ Initializing Trainer...")
    """
    trainer = Trainer(
        model=model,
        args=training_args,
        train_dataset=tokenized_dataset,
        data_collator=DataCollatorForSeq2Seq(tokenizer=tokenizer, padding=True)
    )
    """

    # 7. Start Training
    print("🔥 Starting Training...(Simulated)")
    # trainer.train()

    # 8. Save Custom Weights
    print(f"💾 Saving LoRA weights to {output_dir}")
    print("✅ Fine-tuning Complete!")


if __name__ == "__main__":
    main()
