SET search_path TO dds;

CREATE TABLE "h__user" (
  "h__user__pk" uuid PRIMARY KEY,
  "user_id" text UNIQUE NOT NULL,
  "load_ts" timestamp,
  "record_source" text
);

CREATE TABLE "s__user__email" (
  "s__user__contacs__pk" uuid PRIMARY KEY,
  "h__user__pk" uuid,
  "email" text,
  "valid_from" timestamp,
  "valid_to" timestamp,
  "load_ts" timestamp,
  "record_source" text
);

CREATE TABLE "s__user__phone_number" (
  "s__user__contacs__pk" uuid PRIMARY KEY,
  "h__user__pk" uuid,
  "phone_number" text,
  "valid_from" timestamp,
  "valid_to" timestamp,
  "load_ts" timestamp,
  "record_source" text
);

CREATE TABLE "s__user__birthday" (
  "s__user__contacs__pk" uuid PRIMARY KEY,
  "h__user__pk" uuid,
  "birthday" text,
  "valid_from" timestamp,
  "valid_to" timestamp,
  "load_ts" timestamp,
  "record_source" text
);

CREATE TABLE "s__user__gender" (
  "s__user__contacs__pk" uuid PRIMARY KEY,
  "h__user__pk" uuid,
  "gender" text,
  "valid_from" timestamp,
  "valid_to" timestamp,
  "load_ts" timestamp,
  "record_source" text
);

CREATE TABLE "s__user__registration_channel" (
  "s__user__registration_channel__pk" uuid PRIMARY KEY,
  "h__user__pk" uuid,
  "source" text,
  "medium" text,
  "campaign" text,
  "content" text,
  "registered_at" timestamp,
  "load_ts" timestamp,
  "record_source" text
);

CREATE TABLE "h__session" (
  "h__session__pk" uuid PRIMARY KEY,
  "session_id" text UNIQUE NOT NULL,
  "load_ts" timestamp,
  "record_source" text
);

CREATE TABLE "s__session__start" (
  "s__session__start__pk" uuid PRIMARY KEY,
  "h__session__pk" uuid,
  "session_start_ts" timestamp,
  "load_ts" timestamp,
  "record_source" text
);

CREATE TABLE "s__session__end" (
  "s__session__end__pk" uuid PRIMARY KEY,
  "h__session__pk" uuid,
  "session_end_ts" timestamp,
  "load_ts" timestamp,
  "record_source" text
);

CREATE TABLE "s__session__tech" (
  "s__session__tech__pk" uuid PRIMARY KEY,
  "h__session__pk" uuid,
  "device_type" text,
  "os_name" text,
  "os_version" text,
  "browser_name" text,
  "browser_version" text,
  "load_ts" timestamp,
  "record_source" text
);

CREATE TABLE "s__session__traffic_source" (
  "s__session__traffic_source__pk" uuid PRIMARY KEY,
  "h__session__pk" uuid,
  "source" text,
  "medium" text,
  "campaign" text,
  "content" text,
  "load_ts" timestamp,
  "record_source" text
);

CREATE TABLE "s__session__geo" (
  "s__session__geo__pk" uuid PRIMARY KEY,
  "h__session__pk" uuid,
  "country_code" text,
  "region_name" text,
  "city_name" text,
  "ip_address" text,
  "load_ts" timestamp,
  "record_source" text
);

CREATE TABLE "h__event" (
  "h__event__pk" uuid PRIMARY KEY,
  "event_id" text UNIQUE NOT NULL,
  "load_ts" timestamp,
  "record_source" text
);

CREATE TABLE "s__event__metadata" (
  "s__event__metadata__pk" uuid PRIMARY KEY,
  "h__event__pk" uuid,
  "event_ts" timestamp,
  "event_type" text,
  "context" text,
  "metadata" jsonb,
  "load_ts" timestamp,
  "record_source" text
);

CREATE TABLE "h__product" (
  "h__product__pk" uuid PRIMARY KEY,
  "product_id" text UNIQUE NOT NULL,
  "load_ts" timestamp,
  "record_source" text
);

CREATE TABLE "s__product__info" (
  "s__product__info__pk" uuid PRIMARY KEY,
  "h__product__pk" uuid,
  "name" text,
  "brand" text,
  "valid_from" timestamp,
  "valid_to" timestamp,
  "load_ts" timestamp,
  "record_source" text
);

CREATE TABLE "s__product__price" (
  "s__product__price__pk" uuid PRIMARY KEY,
  "h__product__pk" uuid,
  "price" numeric,
  "currency" text,
  "valid_from" timestamp,
  "valid_to" timestamp,
  "load_ts" timestamp,
  "record_source" text
);

CREATE TABLE "h__category" (
  "h__category__pk" uuid PRIMARY KEY,
  "category_id" text UNIQUE NOT NULL,
  "load_ts" timestamp,
  "record_source" text
);

CREATE TABLE "s__category__name" (
  "s__category__name__pk" uuid PRIMARY KEY,
  "h__category__pk" uuid,
  "category_name" text,
  "valid_from" timestamp,
  "valid_to" timestamp,
  "load_ts" timestamp,
  "record_source" text
);

CREATE TABLE "s__category__hierarchy" (
  "s__category__hierarchy__pk" uuid PRIMARY KEY,
  "h__category__pk" uuid,
  "parent_category_id" text,
  "level" int,
  "valid_from" timestamp,
  "valid_to" timestamp,
  "load_ts" timestamp,
  "record_source" text
);

CREATE TABLE "h__tag" (
  "h__tag__pk" uuid PRIMARY KEY,
  "tag_id" text UNIQUE NOT NULL,
  "load_ts" timestamp,
  "record_source" text
);

CREATE TABLE "s__tag__info" (
  "s__tag__info__pk" uuid PRIMARY KEY,
  "h__tag__pk" uuid,
  "tag_name" text,
  "description" text,
  "load_ts" timestamp,
  "record_source" text
);

CREATE TABLE "h__payment" (
  "h__payment__pk" uuid PRIMARY KEY,
  "payment_id" text UNIQUE NOT NULL,
  "load_ts" timestamp,
  "record_source" text
);

CREATE TABLE "s__payment__info" (
  "s__payment__info__pk" uuid PRIMARY KEY,
  "h__payment__pk" uuid,
  "payment_time" timestamp,
  "amount" numeric,
  "method" text,
  "currency" text,
  "load_ts" timestamp,
  "record_source" text
);

CREATE TABLE "s__payment__status" (
  "s__payment__status__pk" uuid PRIMARY KEY,
  "h__payment__pk" uuid,
  "status" text,
  "load_ts" timestamp,
  "record_source" text
);

CREATE TABLE "h__return" (
  "h__return__pk" uuid PRIMARY KEY,
  "return_id" text UNIQUE NOT NULL,
  "load_ts" timestamp,
  "record_source" text
);

CREATE TABLE "s__return__info" (
  "s__return__info__pk" uuid PRIMARY KEY,
  "h__return__pk" uuid,
  "return_time" timestamp,
  "reason" text,
  "status" text,
  "load_ts" timestamp,
  "record_source" text
);

CREATE TABLE "h__page" (
  "h__page__pk" uuid PRIMARY KEY,
  "page_id" text UNIQUE NOT NULL,
  "load_ts" timestamp,
  "record_source" text
);

CREATE TABLE "s__page__url" (
  "s__page__url__pk" uuid PRIMARY KEY,
  "h__page__pk" uuid,
  "url" text,
  "load_ts" timestamp,
  "record_source" text
);

CREATE TABLE "s__page__type_layout" (
  "s__page__type_layout__pk" uuid PRIMARY KEY,
  "h__page__pk" uuid,
  "page_type" text,
  "layout" text,
  "valid_from" timestamp,
  "valid_to" timestamp,
  "load_ts" timestamp,
  "record_source" text
);

CREATE TABLE "l__user__session" (
  "l__user__session__pk" uuid PRIMARY KEY,
  "h__user__pk" uuid,
  "h__session__pk" uuid,
  "load_ts" timestamp,
  "record_source" text
);

CREATE TABLE "l__user__payment" (
  "l__user__payment__pk" uuid PRIMARY KEY,
  "h__user__pk" uuid,
  "h__payment__pk" uuid,
  "load_ts" timestamp,
  "record_source" text
);

CREATE TABLE "l__payment__product" (
  "l__payment__product__pk" uuid PRIMARY KEY,
  "h__payment__pk" uuid,
  "h__product__pk" uuid,
  "quantity" int,
  "price" numeric,
  "load_ts" timestamp,
  "record_source" text
);

CREATE TABLE "l__product__category" (
  "l__product__category__pk" uuid PRIMARY KEY,
  "h__product__pk" uuid,
  "h__category__pk" uuid,
  "load_ts" timestamp,
  "record_source" text
);

CREATE TABLE "l__product__tag" (
  "l__product__tag__pk" uuid PRIMARY KEY,
  "h__product__pk" uuid,
  "h__tag__pk" uuid,
  "load_ts" timestamp,
  "record_source" text
);

CREATE TABLE "l__event__session" (
  "l__event__session__pk" uuid PRIMARY KEY,
  "h__event__pk" uuid,
  "h__session__pk" uuid,
  "load_ts" timestamp,
  "record_source" text
);

CREATE TABLE "l__event__page" (
  "l__event__page__pk" uuid PRIMARY KEY,
  "h__event__pk" uuid,
  "h__page__pk" uuid,
  "load_ts" timestamp,
  "record_source" text
);

CREATE TABLE "l__event__product" (
  "l__event__product__pk" uuid PRIMARY KEY,
  "h__event__pk" uuid,
  "h__product__pk" uuid,
  "load_ts" timestamp,
  "record_source" text
);

CREATE TABLE "l__page__product" (
  "l__page__product__pk" uuid PRIMARY KEY,
  "h__page__pk" uuid,
  "h__product__pk" uuid,
  "load_ts" timestamp,
  "record_source" text
);

CREATE TABLE "l__page__category" (
  "l__page__category__pk" uuid PRIMARY KEY,
  "h__page__pk" uuid,
  "h__category__pk" uuid,
  "load_ts" timestamp,
  "record_source" text
);

CREATE TABLE "l__return__payment" (
  "l__return__payment__pk" uuid PRIMARY KEY,
  "h__return__pk" uuid,
  "h__payment__pk" uuid,
  "load_ts" timestamp,
  "record_source" text
);

CREATE TABLE "l__return__product" (
  "l__return__product__pk" uuid PRIMARY KEY,
  "h__return__pk" uuid,
  "h__product__pk" uuid,
  "quantity" int,
  "return_amount" numeric,
  "load_ts" timestamp,
  "record_source" text
);

ALTER TABLE "s__user__email" ADD FOREIGN KEY ("h__user__pk") REFERENCES "h__user" ("h__user__pk");

ALTER TABLE "s__user__phone_number" ADD FOREIGN KEY ("h__user__pk") REFERENCES "h__user" ("h__user__pk");

ALTER TABLE "s__user__birthday" ADD FOREIGN KEY ("h__user__pk") REFERENCES "h__user" ("h__user__pk");

ALTER TABLE "s__user__gender" ADD FOREIGN KEY ("h__user__pk") REFERENCES "h__user" ("h__user__pk");

ALTER TABLE "s__user__registration_channel" ADD FOREIGN KEY ("h__user__pk") REFERENCES "h__user" ("h__user__pk");

ALTER TABLE "s__session__start" ADD FOREIGN KEY ("h__session__pk") REFERENCES "h__session" ("h__session__pk");

ALTER TABLE "s__session__end" ADD FOREIGN KEY ("h__session__pk") REFERENCES "h__session" ("h__session__pk");

ALTER TABLE "s__session__tech" ADD FOREIGN KEY ("h__session__pk") REFERENCES "h__session" ("h__session__pk");

ALTER TABLE "s__session__traffic_source" ADD FOREIGN KEY ("h__session__pk") REFERENCES "h__session" ("h__session__pk");

ALTER TABLE "s__session__geo" ADD FOREIGN KEY ("h__session__pk") REFERENCES "h__session" ("h__session__pk");

ALTER TABLE "s__event__metadata" ADD FOREIGN KEY ("h__event__pk") REFERENCES "h__event" ("h__event__pk");

ALTER TABLE "s__product__info" ADD FOREIGN KEY ("h__product__pk") REFERENCES "h__product" ("h__product__pk");

ALTER TABLE "s__product__price" ADD FOREIGN KEY ("h__product__pk") REFERENCES "h__product" ("h__product__pk");

ALTER TABLE "s__category__name" ADD FOREIGN KEY ("h__category__pk") REFERENCES "h__category" ("h__category__pk");

ALTER TABLE "s__category__hierarchy" ADD FOREIGN KEY ("h__category__pk") REFERENCES "h__category" ("h__category__pk");

ALTER TABLE "s__tag__info" ADD FOREIGN KEY ("h__tag__pk") REFERENCES "h__tag" ("h__tag__pk");

ALTER TABLE "s__payment__info" ADD FOREIGN KEY ("h__payment__pk") REFERENCES "h__payment" ("h__payment__pk");

ALTER TABLE "s__payment__status" ADD FOREIGN KEY ("h__payment__pk") REFERENCES "h__payment" ("h__payment__pk");

ALTER TABLE "s__return__info" ADD FOREIGN KEY ("h__return__pk") REFERENCES "h__return" ("h__return__pk");

ALTER TABLE "s__page__url" ADD FOREIGN KEY ("h__page__pk") REFERENCES "h__page" ("h__page__pk");

ALTER TABLE "s__page__type_layout" ADD FOREIGN KEY ("h__page__pk") REFERENCES "h__page" ("h__page__pk");

ALTER TABLE "l__user__session" ADD FOREIGN KEY ("h__user__pk") REFERENCES "h__user" ("h__user__pk");

ALTER TABLE "l__user__session" ADD FOREIGN KEY ("h__session__pk") REFERENCES "h__session" ("h__session__pk");

ALTER TABLE "l__user__payment" ADD FOREIGN KEY ("h__user__pk") REFERENCES "h__user" ("h__user__pk");

ALTER TABLE "l__user__payment" ADD FOREIGN KEY ("h__payment__pk") REFERENCES "h__payment" ("h__payment__pk");

ALTER TABLE "l__payment__product" ADD FOREIGN KEY ("h__payment__pk") REFERENCES "h__payment" ("h__payment__pk");

ALTER TABLE "l__payment__product" ADD FOREIGN KEY ("h__product__pk") REFERENCES "h__product" ("h__product__pk");

ALTER TABLE "l__product__category" ADD FOREIGN KEY ("h__product__pk") REFERENCES "h__product" ("h__product__pk");

ALTER TABLE "l__product__category" ADD FOREIGN KEY ("h__category__pk") REFERENCES "h__category" ("h__category__pk");

ALTER TABLE "l__product__tag" ADD FOREIGN KEY ("h__product__pk") REFERENCES "h__product" ("h__product__pk");

ALTER TABLE "l__product__tag" ADD FOREIGN KEY ("h__tag__pk") REFERENCES "h__tag" ("h__tag__pk");

ALTER TABLE "l__event__session" ADD FOREIGN KEY ("h__event__pk") REFERENCES "h__event" ("h__event__pk");

ALTER TABLE "l__event__session" ADD FOREIGN KEY ("h__session__pk") REFERENCES "h__session" ("h__session__pk");

ALTER TABLE "l__event__page" ADD FOREIGN KEY ("h__event__pk") REFERENCES "h__event" ("h__event__pk");

ALTER TABLE "l__event__page" ADD FOREIGN KEY ("h__page__pk") REFERENCES "h__page" ("h__page__pk");

ALTER TABLE "l__event__product" ADD FOREIGN KEY ("h__event__pk") REFERENCES "h__event" ("h__event__pk");

ALTER TABLE "l__event__product" ADD FOREIGN KEY ("h__product__pk") REFERENCES "h__product" ("h__product__pk");

ALTER TABLE "l__page__product" ADD FOREIGN KEY ("h__page__pk") REFERENCES "h__page" ("h__page__pk");

ALTER TABLE "l__page__product" ADD FOREIGN KEY ("h__product__pk") REFERENCES "h__product" ("h__product__pk");

ALTER TABLE "l__page__category" ADD FOREIGN KEY ("h__page__pk") REFERENCES "h__page" ("h__page__pk");

ALTER TABLE "l__page__category" ADD FOREIGN KEY ("h__category__pk") REFERENCES "h__category" ("h__category__pk");

ALTER TABLE "l__return__payment" ADD FOREIGN KEY ("h__return__pk") REFERENCES "h__return" ("h__return__pk");

ALTER TABLE "l__return__payment" ADD FOREIGN KEY ("h__payment__pk") REFERENCES "h__payment" ("h__payment__pk");

ALTER TABLE "l__return__product" ADD FOREIGN KEY ("h__return__pk") REFERENCES "h__return" ("h__return__pk");

ALTER TABLE "l__return__product" ADD FOREIGN KEY ("h__product__pk") REFERENCES "h__product" ("h__product__pk");
