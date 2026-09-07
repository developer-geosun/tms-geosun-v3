export type DocumentTypeListViewContract = 'active' | 'all' | 'deleted';

export interface DocumentTypeScanPageContractDto {
  key: string;
  legendEn: string;
  legendUa: string;
  legendRu: string;
}

export interface DocumentTypeFieldDefinitionContractDto {
  key: string;
  nameUk: string;
  nameEn: string;
  nameRu: string;
  required: boolean;
}

export interface DocumentTypeReferenceContractDto {
  id: string;
  nameUk: string;
  nameEn: string;
  nameRu: string;
  countryCode: string;
  plannedScanPages: DocumentTypeScanPageContractDto[];
  comment: string;
  fieldDefinitions: DocumentTypeFieldDefinitionContractDto[];
  deleted: boolean;
  deletedAt: string | null;
  createdAt: string;
  updatedAt: string;
}

export interface CreateDocumentTypeContractRequest {
  nameUk: string;
  nameEn: string;
  nameRu: string;
  countryCode: string;
  plannedScanPages: DocumentTypeScanPageContractDto[];
  comment: string;
  fieldDefinitions: DocumentTypeFieldDefinitionContractDto[];
}

export type UpdateDocumentTypeContractRequest = CreateDocumentTypeContractRequest;
