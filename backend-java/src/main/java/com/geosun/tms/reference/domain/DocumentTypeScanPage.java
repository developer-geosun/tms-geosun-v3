package com.geosun.tms.reference.domain;

/** Одна сторінка скана в planned_scan_pages: ключ і легенди трьома мовами. */
public record DocumentTypeScanPage(String key, String legendEn, String legendUa, String legendRu) {}
