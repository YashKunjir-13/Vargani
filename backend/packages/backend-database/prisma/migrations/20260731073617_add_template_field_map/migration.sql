-- CreateTable
CREATE TABLE "template_field_map" (
    "id" UUID NOT NULL,
    "template_id" UUID NOT NULL,
    "field_key" VARCHAR(100) NOT NULL,
    "page" INTEGER NOT NULL DEFAULT 1,
    "x" DECIMAL(10,4) NOT NULL,
    "y" DECIMAL(10,4) NOT NULL,
    "font_size" INTEGER NOT NULL DEFAULT 12,
    "detection_confidence" DECIMAL(5,4),

    CONSTRAINT "template_field_map_pkey" PRIMARY KEY ("id")
);

-- AddForeignKey
ALTER TABLE "template_field_map" ADD CONSTRAINT "template_field_map_template_id_fkey" FOREIGN KEY ("template_id") REFERENCES "receipt_templates"("id") ON DELETE CASCADE ON UPDATE CASCADE;
